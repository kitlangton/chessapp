require_relative '../../app/models/piece'
require_relative '../../app/models/chess'
require 'rainbow'

describe Chess do

  context 'new game' do

    xit 'sets up a new board' do

      output = <<-EOF.chomp
    a   b   c   d   e   f   g   h

1   R   N   B   Q   K   B   N   R   1

2   p   p   p   p   p   p   p   p   2

3   .   .   .   .   .   .   .   .   3

4   .   .   .   .   .   .   .   .   4

5   .   .   .   .   .   .   .   .   5

6   .   .   .   .   .   .   .   .   6

7   p   p   p   p   p   p   p   p   7

8   R   N   B   Q   K   B   N   R   8

    a   b   c   d   e   f   g   h
      EOF

      chess = Chess.new
      expect(chess.render_board).to eq output
    end
  end

  it 'moves a piece to a different square' do
    chess = Chess.new
    piece = chess.get_piece("a2")
    chess.move_piece("a2", "a3")
    expect(chess.get_piece("a3")).to eq piece
    expect(chess.get_piece("a2")).to be_a NoPiece
  end


  context 'Bishop' do

    it 'can move diagonally' do
      chess = Chess.new
      bishop = chess.place_piece_on_board(Bishop, :bottom, "d4")
      # puts chess.render_moves_for(bishop, 'd4'.to_coord)

      coords = %W{ c3 b2 c5 b6 e3 f2 e5 f6}
      coords = coords.map(&:to_coord)

      expect(chess.moves_for("d4")).to eq coords
    end

  end

  context 'Rook' do

    it 'can move orthogonally' do
      chess = Chess.new
      rook = chess.place_piece_on_board(Rook, :bottom, "d4")
      # puts chess.render_moves_for(rook, 'd4'.to_coord)

      coords = %W{ d3 d2 e4 f4 g4 h4 d5 d6 c4 b4 a4}
      coords = coords.map(&:to_coord)

      expect(chess.moves_for("d4")).to eq coords
    end

  end

  context 'Knight' do

    it 'can move in L shapes' do
      chess = Chess.new
      knight = chess.place_piece_on_board(Knight, :bottom, "d5")
      chess.place_piece_on_board(Knight, :top, "b4")

      # puts chess.render_moves_for(knight, 'd5'.to_coord)

      coords = %W{ c3 e3 f4 f6 b6 b4 }
      coords = coords.map(&:to_coord)

      expect(chess.attacks_for("d5")).to eq coords
    end

  end

  context 'Queen' do

    it 'can move diagonally and orthogonally' do
      chess = Chess.new
      queen = chess.place_piece_on_board(Queen, :bottom, "d4")
      # puts chess.render_moves_for(queen, 'd4'.to_coord)

      coords = %W{ d3 d2 e4 f4 g4 h4 d5 d6 c4 b4 a4 c3 b2 c5 b6 e3 f2 e5 f6 }
      coords = coords.map(&:to_coord)

      expect(chess.moves_for("d4")).to eq coords
    end

  end

  context 'Pawn' do

    it 'can move one space ahead' do
      chess = Chess.new
      pawn = chess.place_piece_on_board(Pawn, :bottom, "d4")
      # puts chess.render_moves_for(pawn, 'd4'.to_coord)

      coords = %W{ d3 }
      coords = coords.map(&:to_coord)

      expect(chess.moves_for("d4")).to eq coords
    end

    it 'can move one or two moves if its on its initial row' do
      chess = Chess.new
      pawn = chess.place_piece_on_board(Pawn, :bottom, "d7")
      # puts chess.render_moves_for(pawn, 'd7'.to_coord)

      coords = %W{ d6 d5 }
      coords = coords.map(&:to_coord)

      expect(chess.moves_for("d7")).to eq coords
    end

    it 'attacks diagonally one space' do
      chess = Chess.new
      pawn = chess.place_piece_on_board(Pawn, :bottom, "b3")
      # puts chess.render_moves_for(pawn, 'b3'.to_coord)

      coords = %W{ a2 c2 }
      coords = coords.map(&:to_coord)

      expect(chess.moves_for("b3")).to eq coords
    end

  end

  context 'King' do

    it 'can move one space in any direction' do
      chess = Chess.new
      king = chess.place_piece_on_board(King, :bottom, "d5")

      coords = %W{ c4 c6 e4 e6 d4 e5 d6 c5 }
      coords = coords.map(&:to_coord)

      expect(chess.moves_for("d5")).to eq coords
    end

    it 'it cannot move into check' do
      chess = Chess.new
      king = chess.place_piece_on_board(King, :bottom, "d4")
      # puts chess.render_moves_for(king, 'd4'.to_coord)

      coords = %W{ c5 e5 e4 d5 c4 }
      coords = coords.map(&:to_coord)

      expect(chess.moves_for("d4")).to eq coords
    end

  end

  it 'knows whether or not a king is in check' do
    chess = Chess.new

    king = chess.place_piece_on_board(King, :bottom, "d4")
    chess.place_piece_on_board(Bishop, :top, "e5")

    puts chess.render_moves_for(king, 'd4'.to_coord)

    expect(chess.board.in_check?('d4'.to_coord)).to eq true
    expect(chess.board.in_check?('a1'.to_coord)).to eq false
  end

  it 'keeps track of fallen pieces' do
    chess = Chess.new
    pawn = chess.place_piece_on_board(Pawn, :bottom, "d3")
    chess.move_piece('b2','d3')
    expect(chess.graveyard).to eq [pawn]
  end

end

describe Board do

  it 'can store pieces at a given position' do
    board = Board.new
    piece = double(:piece)
    coordinate = Coordinate.new(x: 5, y:5, piece: nil)
    board.place_piece(piece, coordinate)
    expect(board.get_piece(coordinate)).to eq piece
  end

end

