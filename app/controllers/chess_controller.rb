class ChessController < ApplicationController
  require 'chess'

  def index
  end

  def show

    game = Game.last

    # reset
    # game.state = Chess.new
    # game.save

    @chess = game.state

  end

  def move
    game = Game.last
    chess = game.state
    from , to = params[:move].values
    chess.move_piece(from, to)
    game.state = chess
    game.save
    @chess = game.state
    respond_to do |format|
      format.json { render json: { success: true, html: (render_to_string 'chess/_board.html.erb', layout: false) } }
    end
  end
end
