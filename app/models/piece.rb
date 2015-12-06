class Piece
  attr_accessor :color

  def initialize(input = {})
    @color = input.fetch(:color)
  end

  def possible_moves(coordinate, board)
    []
  end

  def possible_attacks(coordinate, board)
    []
  end

  def other_color
    if top?
      :bottom
    elsif bottom?
      :top
    end
  end

  def enemy?(other_piece)
    if color == :bottom && other_piece.color == :top ||
        color == :top && other_piece.color == :bottom
      return true
    end
    false
  end

  def friendly?(other_piece)
    if color == :bottom && other_piece.color == :bottom ||
        color == :top && other_piece.color == :top
      return true
    end
    false
  end

  def top?
    color == :top
  end

  def bottom?
    color == :bottom
  end

end

class NoPiece < Piece

  def initialize(color: :none)
    super
  end


  def to_s
    '.'
  end

  def possible_attacks(coordinate, board)
    possible_moves(coordinate, board)
  end
end

class Rook < Piece
  def to_s
    'R'
  end

  def possible_moves(coordinate, board)
    moves = []

    board.orthogonals_from(coordinate).each do |direction|
      direction.each do |coord|
        if enemy?(coord.piece)
          moves << coord
        end

        break if coord.occupied?

        moves << coord
      end
    end

    moves
  end

  def possible_attacks(coordinate, board)
    possible_moves(coordinate, board)
  end
end

class Knight < Piece
  def to_s
    'N'
  end

  def possible_moves(coordinate, board)
    moves = []

    board.l_shapes_from(coordinate).each do |coord|
      if coord.empty? || enemy?(coord.piece)
        moves << coord
      end
    end

    moves
  end

  def possible_attacks(coordinate, board)
    possible_moves(coordinate, board)
  end

end

class Bishop < Piece
  def to_s
    'B'
  end

  def possible_moves(coordinate, board)
    moves = []

    board.diagonals_from(coordinate).each do |direction|
      direction.each do |coord|
        if enemy?(coord.piece)
          moves << coord
        end

        break if coord.occupied?

        moves << coord
      end
    end

    moves
  end

  def possible_attacks(coordinate, board)
    possible_moves(coordinate, board)
  end

end

class Queen < Piece
  def to_s
    'Q'
  end


  def possible_moves(coordinate, board)
    moves = []
    moves << Rook.new(color: color).possible_moves(coordinate, board)
    moves << Bishop.new(color: color).possible_moves(coordinate, board)
    moves.flatten(1)
  end

  def possible_attacks(coordinate, board)
    possible_moves(coordinate, board)
  end
end

class King < Piece
  def to_s
    'K'
  end

  def possible_moves(coordinate, board)
    enemy_moves = board.moves_for_team(other_color)

    possible_attacks(coordinate, board).map do |coord|
      if friendly?(coord.piece)
        nil
      elsif enemy_moves.any? { |move| move == coord}
        nil
      else
        coord
      end
    end.compact
  end

  def possible_attacks(coordinate, board)
    attacks = []

    board.diagonals_from(coordinate).each do |direction|
      direction.each do |coord|
        attacks << coord

        break
      end
    end

    board.orthogonals_from(coordinate).each do |direction|
      direction.each do |coord|
        attacks << coord
        break
      end
    end

    attacks.reject { |coord| friendly?(coord.piece) }
  end

end

class Pawn < Piece
  def to_s
    'p'
  end

  def possible_moves(coordinate, board)
    moves = []

    moves << single_space_move(coordinate, board)
    moves << double_space_move(coordinate, board)

    moves = moves.compact.reject { |move| move.occupied? }

    attacks = possible_attacks(coordinate, board).select do |coord|
      enemy?(coord.piece)
    end

    moves << attacks


    moves.flatten(1).compact
  end

  def possible_attacks(coordinate, board)
    attacks = []

    board.diagonals_ahead(coordinate, direction).each do |coord|
      attacks << coord
    end

    attacks
  end

  def single_space_move(coordinate, board)
    coord = coordinate.send(direction)
    board.get_coordinate(coord)
  end

  def double_space_move(coordinate, board)
    return unless home_row?(coordinate)
    coord = coordinate.send(direction)
    coord = coord.send(direction)
    board.get_coordinate(coord)
  end

  def home_row?(coordinate)
    top? && coordinate.y == 2 ||
      bottom? && coordinate.y == 7
  end

  def direction
    if top?
      :down
    elsif bottom?
      :up
    end
  end

end

