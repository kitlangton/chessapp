class ChessController < ApplicationController
  require 'stats'
  require 'chess'

  def index
  end

  def pick_red
    session[:team] = 'red'
    hash = Game.create(state: Chess.new, stats: Stats.new(creator: 'red')).to_param
    respond_to do |format|
      format.json { render json: { success: true, link: new_game_url(id: hash)} }
    end
  end

  def pick_blue
    session[:team] = 'blue'
    hash = Game.create(state: Chess.new, stats: Stats.new(creator: 'blue')).to_param
    respond_to do |format|
      format.json { render json: { success: true, link: new_game_url(id: hash)} }
    end
  end

  def new
  end

  def show
    id = Hashids.new("checkmate", 8).decode(params[:id]).try(:first)
    game = Game.find(id)

    unless session[:team]
      session[:team] = stats.other_team
    end

    @player = session[:team]
    @id = id

    # reset
    # game.state = Chess.new
    # game.save

    @chess = game.state
  end

  def game_state
    game = Game.find(params[:id])
    stats = game.stats

    unless session[:team]
      session[:team] = stats.other_team
    end

    @player = session[:team]

    if @player == 'red'
      stats.touch_red
    else
      stats.touch_blue
    end


    red_active, blue_active = stats.red_active?, stats.blue_active?

    game.save

    chess = game.state
    @new_dead = chess.new_dead
    @chess = game.state
    turn = @chess.color_to_red_blue(@chess.turn)

    respond_to do |format|
      format.json { render json: { success: true, red_active: red_active, blue_active: blue_active, status: @chess.status, turn: turn, html: (render_to_string 'chess/_board.html.erb', layout: false), graveyard: (render_to_string 'chess/_graveyard.html.erb', layout: false) } }
    end
  end

  def move
    game = Game.find(params[:id])
    stats = game.stats

    if @player == 'red'
      stats.touch_red
    else
      stats.touch_blue
    end

    red_active, blue_active = stats.red_active?, stats.blue_active?

    chess = game.state
    from , to = params[:move].values
    chess.move_piece(from, to)

    @new_dead = chess.new_dead
    @chess = game.state
    turn = @chess.color_to_red_blue(@chess.turn)

    game.state = chess
    game.save

    respond_to do |format|
      format.json { render json: { success: true, red_active: red_active, blue_active: blue_active, status: @chess.status, turn: turn, html: (render_to_string 'chess/_board.html.erb', layout: false), graveyard: (render_to_string 'chess/_graveyard.html.erb', layout: false) } }
    end
  end
end
