require 'piece'

class String
  def to_coord
    letters = { 'a' => 1,
      'b' => 2,
      'c' => 3,
      'd' => 4,
      'e' => 5,
      'f' => 6,
      'g' => 7,
      'h' => 8,
    }
    x, y = self.chars
    Coordinate.new(x: letters[x], y: y.to_i)
  end
end

class Chess

  attr_accessor :board, :turn, :graveyard

  def initialize
    @board = Board.new
    @turn = :bottom
    @new_dead = []
    @graveyard = []
    set_up_board
  end


  def self.from_array(array)
    chess = Chess.new
    chess.board.board.map do |coord|
      coord.piece = NoPiece.new
    end

    array.each_with_index do |pieces, column|
      pieces.each_with_index do |piece, row|
        chess.board.place_piece(piece, Coordinate.new(x: row + 1, y: column + 1))
      end
    end

    chess
  end

  def new_dead
    new = @new_dead
    @new_dead = []
    new
  end

  def move_piece(from, to)
    taken_piece = get_piece(to)

    board.move_piece(from.to_coord, to.to_coord)

    if taken_piece.top? || taken_piece.bottom?
      graveyard << taken_piece
      new_dead << taken_piece
    end

    @turn = (@turn == :top ? :bottom : :top)
  end

  def moves_for(coordinate)
    board.moves_for(coordinate.to_coord)
  end

  def attacks_for(coordinate)
    board.attacks_for(coordinate.to_coord)
  end

  def rows_array
    columns = []
    each_row do |row|
      rows = []
      each_column do |column|
        rows << get_piece("#{column}#{row}")
      end
      columns << rows
    end
    columns
  end

  def set_up_board
    set_up_side(:top, '1')
    set_up_side(:bottom, '8')
  end

  def place_piece_on_board(klass,color,position)
    piece = klass.new(color: color)
    board.place_piece(piece, position.to_coord)
  end

  def set_up_side(color, row)
    place_piece_on_board(Rook, color, "a#{row}")
    place_piece_on_board(Knight, color, "b#{row}")
    place_piece_on_board(Bishop, color, "c#{row}")
    place_piece_on_board(Queen, color, "d#{row}")
    place_piece_on_board(King, color, "e#{row}")
    place_piece_on_board(Bishop, color, "f#{row}")
    place_piece_on_board(Knight, color, "g#{row}")
    place_piece_on_board(Rook, color, "h#{row}")

    set_up_pawns(color)
  end

  def set_up_pawns(color)
    each_column do |column|
      piece = Pawn.new(color: color)
      board.place_piece(piece, "#{column}#{pawn_row_for(color)}".to_coord)
    end
  end

  def pawn_row_for(color)
    color == :bottom ?  '7' : '2'
  end

  def render_board
    display = []
    display << [" ", letters]
    each_row do |row|
      row_array = []
      row_array << row
      each_column do |column|
        piece = get_piece("#{column}#{row}")
        row_array << ( colorize(piece) || '.')
      end
      row_array << row
      display << row_array
    end

    display << [" ", letters]
    display.map do |row|
      row.join("   ")
    end.join("\n\n")
  end

  def render_moves_for(target, coord)
    display = []
    display << [" ", letters]
    each_row do |row|
      row_array = []
      row_array << row
      each_column do |column|
        piece = get_piece("#{column}#{row}")
        output = ( colorize(piece) || '.')
        if target.possible_moves(coord, board).include?("#{column}#{row}".to_coord)
          row_array << Rainbow(output).background(:green)
        else
          row_array << output
        end
      end
      row_array << row
      display << row_array
    end

    display << [" ", letters]
    display.map do |row|
      row.join("   ")
    end.join("\n\n")
  end

  def colorize(piece)
    color =
      case
      when piece.color == :bottom
        :red
      when piece.color == :top
        :blue
      else :nocolor
        :white
      end
    Rainbow(piece.to_s).send(color)
  end

  def get_piece(coordinate)
    board.get_piece(coordinate.to_coord)
  end

  def each_column
    letters.each do |column|
      yield(column)
    end
  end

  def each_row
    (1..8).each do |row|
      yield(row)
    end
  end

  def letters
    %W{ a b c d e f g h }
  end

end


class Board

  attr_accessor :board

  def initialize
    @board = []
    set_up_board
  end

  def moves_for_team(color)
    coords = board.map do |coord|
      if coord.piece.color == color
        coord
      end
    end

    coords = coords.compact

    moves = []

    coords.each do |coord|
      possible_attacks = coord.piece.possible_attacks(coord, self)
      moves <<  possible_attacks
    end

    moves.flatten.uniq
  end

  def moves_for_team(color)
    coords = board.map do |coord|
      if coord.piece.color == color
        coord
      end
    end

    coords = coords.compact

    moves = []

    coords.each do |coord|
      possible_attacks = coord.piece.possible_attacks(coord, self)
      moves <<  possible_attacks
    end

    moves.flatten.uniq
  end

  def in_check?(coordinate)
    piece = get_piece(coordinate)
    moves_for_team(piece.other_color).any?{ |x| x == coordinate }
  end

  def pieces_for_color(color)
    all_pieces.select {|piece| piece.color == color }
  end

  def moves_for(coordinate)
    piece = get_piece(coordinate)
    piece.possible_moves(coordinate, self)
  end

  def attacks_for(coordinate)
    piece = get_piece(coordinate)
    piece.possible_attacks(coordinate, self)
  end

  def cast_from(direction, coordinate)
    coords = []
    coord = coordinate

    loop do
      coord = coord.send(direction)
      break unless on_board?(coord)
      coords << get_coordinate(coord)
    end

    coords
  end

  def l_shapes_from(coordinate)
    coords = []
    coords << coordinate.up.up.left
    coords << coordinate.up.up.right
    coords << coordinate.right.right.up
    coords << coordinate.right.right.down
    coords << coordinate.down.down.right
    coords << coordinate.down.down.left
    coords << coordinate.left.left.down
    coords << coordinate.left.left.up
    coords.map { |coord| get_coordinate(coord) }.compact
  end

  def diagonals_from(coordinate)
    coords = []
    coords << up_left_from(coordinate)
    coords << down_left_from(coordinate)
    coords << up_right_from(coordinate)
    coords << down_right_from(coordinate)
    coords
  end

  def diagonals_ahead(coordinate, direction)
    coords = []
    if direction == :down
      coords << coordinate.down_left
      coords << coordinate.down_right
    else
      coords << coordinate.up_left
      coords << coordinate.up_right
    end
    coords.map{ |coord| get_coordinate(coord) }.compact
  end

  def orthogonals_from(coordinate)
    coords = []
    coords << up_from(coordinate)
    coords << right_from(coordinate)
    coords << down_from(coordinate)
    coords << left_from(coordinate)
    coords
  end

  def up_left_from(coordinate)
    cast_from(:up_left, coordinate)
  end

  def up_from(coordinate)
    cast_from(:up, coordinate)
  end

  def up_right_from(coordinate)
    cast_from(:up_right, coordinate)
  end

  def right_from(coordinate)
    cast_from(:right, coordinate)
  end

  def down_right_from(coordinate)
    cast_from(:down_right, coordinate)
  end

  def down_from(coordinate)
    cast_from(:down, coordinate)
  end

  def down_left_from(coordinate)
    cast_from(:down_left, coordinate)
  end

  def left_from(coordinate)
    cast_from(:left, coordinate)
  end

  def on_board?(coordinate)
    !!get_coordinate(coordinate)
  end

  def move_piece(from, to)
    piece = get_piece(from)
    place_piece(piece, to)
    clear_coordinate(from)
  end

  def clear_coordinate(coordinate)
    coordinate = get_coordinate(coordinate)
    coordinate.piece = NoPiece.new
  end

  def set_up_board
    (1..8).each do |i|
      (1..8).each do |j|
        board << Coordinate.new(x: i, y: j, piece: NoPiece.new)
      end
    end
  end

  def place_piece(piece, given_coordinate)
    coordinate = get_coordinate(given_coordinate)
    coordinate.piece = piece
  end

  def get_coordinate(given_coordinate)
    board.find { |coordinate| coordinate == given_coordinate }
  end

  def get_piece(given_coordinate)
    get_coordinate(given_coordinate).piece
  end
end

class Coordinate

  attr_accessor :x, :y, :piece

  def initialize(input = {})
    @x = input.fetch(:x)
    @y = input.fetch(:y)
    @piece = input.fetch(:piece, NoPiece.new)
  end

  def ==(other_coordinate)
    other_coordinate.x == x && other_coordinate.y == y
  end

  def occupied?
    !piece.is_a?(NoPiece)
  end

  def empty?
    !occupied?
  end


  def to_s
    letters = {
      'a' => 1,
      'b' => 2,
      'c' => 3,
      'd' => 4,
      'e' => 5,
      'f' => 6,
      'g' => 7,
      'h' => 8,
    }

    "#{letters.invert[x]}#{y}"
  end

  def up_left
    Coordinate.new(x: x - 1, y: y - 1)
  end

  def up
    Coordinate.new(x: x , y: y - 1)
  end

  def up_right
    Coordinate.new(x: x + 1, y: y - 1)
  end

  def right
    Coordinate.new(x: x + 1, y: y )
  end

  def down_right
    Coordinate.new(x: x + 1, y: y + 1 )
  end

  def down
    Coordinate.new(x: x, y: y + 1 )
  end

  def down_left
    Coordinate.new(x: x - 1, y: y + 1 )
  end

  def left
    Coordinate.new(x: x - 1, y: y )
  end

  def inspect
    "Coord:<#{to_s}>"
  end

end
