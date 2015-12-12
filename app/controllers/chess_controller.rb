class ChessController < ApplicationController
  require 'stats'
  require 'chess'

  def index
  end

  def pick_red
    hash = Game.create(state: Chess.new, stats: Stats.new(creator: 'red')).to_param
    cookies[hash.to_sym] ||= {value: 'red', expires: 1.year.from_now.utc}
    respond_to do |format|
      format.json { render json: { success: true, link: new_game_url(id: hash), sharelink: new_game_url(id: hash)} }
    end
  end

  def pick_blue
    hash = Game.create(state: Chess.new, stats: Stats.new(creator: 'blue')).to_param
    cookies[hash.to_sym] ||= {value: 'blue', expires: 1.year.from_now.utc}
    respond_to do |format|
      format.json { render json: { success: true, link: new_game_url(id: hash), sharelink: new_game_url(id: hash)} }
    end
  end

  def new
  end

  def show
    id = Hashids.new("checkmate", 8).decode(params[:id]).try(:first)
    game = Game.find(id)
    stats = game.stats
    hash = game.to_param

    cookies[hash.to_sym] ||= {value: stats.other_team, expires: 1.year.from_now.utc}

    @link = new_game_url(game)
    @player = cookies[hash.to_sym]
    @id = id

    # reset
    # game.state = Chess.new
    # game.save

    @chess = game.state
  end

  def game_state
    game = Game.find(params[:id])
    hash = game.to_param
    stats = game.stats

    cookies[hash.to_sym] ||= {value: stats.other_team, expires: 1.year.from_now.utc}
    @player = cookies[hash.to_sym]

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
    last_move = @chess.last_move
    turn = @chess.color_to_red_blue(@chess.turn)

    respond_to do |format|
      format.json { render json: { success: true, last_move: last_move, red_active: red_active, blue_active: blue_active, status: @chess.status, turn: turn, html: (render_to_string 'chess/_board.html.erb', layout: false), graveyard: (render_to_string 'chess/_graveyard.html.erb', layout: false) } }
    end
  end

  def move
    game = Game.find(params[:id])
    stats = game.stats
    hash = game.to_param

    cookies[hash.to_sym] ||= {value: stats.other_team, expires: 1.year.from_now.utc}
    @player = cookies[hash.to_sym]

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
