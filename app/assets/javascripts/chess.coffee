# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

# $ ->
#   $('.piece').hover ->
#     $('body').addClass "blue"
#   , ->
#     $('body').removeClass "blue"

checkmated = ->
  $('.checkmate').find(".piece:not(.king)").velocity
    opacity: 0
  ,
    duration: 500
  $('.checkmate').find(".king").velocity
    translateY: "-30px"
    opacity: 1
    scale: 2
  ,
    delay: 500
    duration: 500
  $('.checkmate').find("td").addClass("checkmate-bg")

update_state = (player) ->
  $.ajax
    type: "GET"
    url: "/chess/game_state"
    success: (data) ->
      unless !window.updated && data.turn == player
        setTimeout ->
          update_state(player)
        ,
          3000
        return
      window.updated = true
      console.log data.new_dead
      console.log data
      $('.board-container').html data.html
      $('.graveyard-container').html data.graveyard
      piece_selected = false
      if data.turn == 'blue'
        window.turn = 'blue'
        $('body').addClass('blue')
      else
        window.turn = 'red'
        $('body').removeClass('blue')
      $(".piece.#{data.turn}-team").velocity 'callout.bounce',
        stagger: 50
        drag: true
      setTimeout ->
        update_state(player)
      ,
        3000
      return false
    error: (data) ->
      console.log data
      return false


$ ->
  $(".piece").css
    opacity: 0
  $(".stone").css
    opacity: 0
  $('#board').velocity "transition.slideUpIn"
  setTimeout ->
    $(".piece").velocity 'transition.slideDownIn',
      stagger: 50
      drag: true
  ,
    500
  setTimeout ->
    $(".stone").velocity 'transition.slideDownIn',
      stagger: 50
      drag: true
  ,
    1500

  window.turn = $("#board").data('turn')
  if window.turn == "top"
    window.turn = "blue"
    $('body').addClass('no-transition')
    $('body').addClass('blue')
    $('body').removeClass('no-transition')
  else
    window.turn = "red"

  player = $("#board").data('player')
  window.updated = window.turn == player
  update_state(player)

  piece_selected = false
  piece = null

  # $(".audio-play")[0].currentTime = 0

  $('body').on 'click', 'td', ->
    unless piece_selected
      unless player == window.turn == $(@).data('color')
        return
      # if $('#board').data('check') == turn
      #   unless $(@).find('.piece').hasClass('king')
      #     return
      $('#move_from').val $(@).data('coord')
      $(@).find(".piece").addClass('selected')
      piece = $(@).find(".piece")
      piece_selected = true

      moves = $(@).data('moves')
      for move in moves
        $("td[data-coord='"+move+"']").addClass("possible_move")
    else
      if $('table').hasClass 'checkmate'
        checkmated()
      unless $(@).hasClass('possible_move')
        piece.removeClass("selected")
        $('.possible_move').each ->
          $(@).removeClass("possible_move")
        piece_selected = false
        return
      $('.in-check').each ->
        $(@).removeClass("in-check")
      piece.removeClass("selected")
      to = $(@).offset()
      from = piece.offset()
      ydist = to.top - from.top
      xdist = to.left - from.left
      $('.possible_move').each ->
        $(@).removeClass("possible_move")
      $(@).find(".piece").velocity "transition.slideUpOut"
      $(piece).velocity
        translateX: "#{xdist}px",
        translateY: "#{ydist}px" 
      $(".audio-play")[0].play()
      $('#move_to').val $(@).data('coord')

      setTimeout ->
        $.ajax
          type: "POST"
          url: "/chess/move"
          data:
            move:
              from: $('#move_from').val()
              to: $('#move_to').val()
          success: (data) ->
            window.updated = false
            $('.board-container').html data.html
            $('.graveyard-container').html data.graveyard
            piece_selected = false
            if window.turn == 'red'
              window.turn = 'blue'
              $('body').addClass('blue')
            else
              window.turn = 'red'
              $('body').removeClass('blue')
            $(".piece.#{window.turn}-team").velocity 'callout.bounce',
              stagger: 50
              drag: true
            return false
          error: (data) ->
            console.log data
            return false
      ,
        100



