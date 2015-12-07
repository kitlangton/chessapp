class ChessController < ApplicationController
  require 'chess'

  def index
  end

  def pick_red
    session[:team] = 'red'
    redirect_to new_game_url
  end

  def pick_blue
    session[:team] = 'blue'
    redirect_to new_game_url
  end


  def show

    game = Game.last

    @player = session[:team]

    # reset
    # game.state = Chess.new
    # game.save

    @chess = game.state
  end

  def game_state
    game = Game.last

    chess = game.state
    @new_dead = chess.new_dead
    @chess = game.state
    turn = @chess.color_to_red_blue(@chess.turn)

    respond_to do |format|
      format.json { render json: { success: true, turn: turn, html: (render_to_string 'chess/_board.html.erb', layout: false), graveyard: (render_to_string 'chess/_graveyard.html.erb', layout: false) } }
    end
  end

  def move
    game = Game.last

    chess = game.state
    from , to = params[:move].values
    chess.move_piece(from, to)
    @new_dead = chess.new_dead
    @chess = game.state
    game.state = chess
    game.save
    respond_to do |format|
      format.json { render json: { success: true, html: (render_to_string 'chess/_board.html.erb', layout: false), graveyard: (render_to_string 'chess/_graveyard.html.erb', layout: false) } }
    end
  end
end
