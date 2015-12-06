# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

# $ ->
#   $('.piece').hover ->
#     $('body').addClass "blue"
#   , ->
#     $('body').removeClass "blue"



$ ->


  turn = $("#board").data('turn')

  if turn == "top"
    turn = "blue"
    $('body').addClass('no-transition')
    $('body').addClass('blue')
    $('body').removeClass('no-transition')
  else
    turn = "red"

  sumbit = ->
    $('form').submit()

  piece_selected = false
  piece = null

  $('body').on 'click', 'td', ->
    unless piece_selected
      unless turn == $(@).data('color')
        return
      $('#move_from').val $(@).data('coord')
      $(@).find(".piece").addClass('selected')
      piece = $(@).find(".piece")
      piece_selected = true

      moves = $(@).data('moves')
      for move in moves
        $("td[data-coord='"+move+"']").addClass("possible_move")
    else
      unless $(@).hasClass('possible_move')
        piece.removeClass("selected")
        $('.possible_move').each ->
          $(@).removeClass("possible_move")
        piece_selected = false
        return
      piece.removeClass("selected")
      to = $(@).offset()
      from = piece.offset()
      ydist = to.top - from.top
      xdist = to.left - from.left
      $('.possible_move').each ->
        $(@).removeClass("possible_move")
      $(piece).velocity
        translateX: "#{xdist}px",
        translateY: "#{ydist}px" 
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
            console.log data
            $('.board-container').html data.html
            piece_selected = false
            if turn == 'red'
              turn = 'blue'
              $('body').addClass('blue')
            else
              turn = 'red'
              $('body').removeClass('blue')
            $(".piece.#{turn}-team").velocity 'callout.bounce',
              stagger: 50
              drag: true
            return false
          error: (data) ->
            console.log data
            return false
      ,
        450



