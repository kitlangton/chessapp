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
  $(".in-check").removeClass 'in-check'
  $(".logo").velocity
    opacity: 0
  $(".stone").velocity 'transition.slideUpOut',
    stagger: 50
    drag: true
  ,
    1500
  $('.checkmate').find(".piece:not(.king)").velocity
    opacity: 0.5
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
  $('body').velocity
    backgroundColor: "#000"

animateCards = ->
  count = -2
  # $('.my-card:not(.card-active)').velocity
  #   opacity: 0
  $('.card-active').each ->
    count += 1
    # $(@).css
    #   opacity: 1
    $(@).stop().velocity
      translateX: "#{80 * count}px"
      rotateZ: "#{10 * count}deg"
    ,
      duration: 800
      easing: 'spring'
  if count > -2
    count += 1
    $('.logo').stop().velocity
      translateX: "#{80 * count}px"
      rotateZ: "#{10 * count}deg"
    ,
      duration: 800
      easing: 'spring'

updateCards = (data) ->
  return if $(".hovering").size() > 0
  check = $("#board").data('check')
  if check
    $(".my-card.#{check}-check-card").addClass('card-active')
  else
    $(".my-card.red-check-card").removeClass('card-active')
    $(".my-card.blue-check-card").removeClass('card-active')
  if data.red_active
    $(".red-team.inactive").removeClass('inactive')
    $(".my-card.red-idle-card").removeClass('card-active')
    # $(".my-card.red-idle-card > .back").removeClass('card-active')
  else
    $(".red-team").addClass('inactive')
    $(".my-card.red-idle-card").addClass('card-active')
    # $(".my-card.red-idle-card > .back").addClass('card-active')
  if data.blue_active
    $(".blue-team.inactive").removeClass('inactive')
    $(".my-card.blue-idle-card").removeClass('card-active')
    # $(".my-card.blue-idle-card > .back").removeClass('card-active')
  else
    $(".blue-team").addClass('inactive')
    $(".my-card.blue-idle-card").addClass('card-active')
    # $(".my-card.blue-idle-card > .back").addClass('card-active')
  if data.turn == 'red'
    $(".blue-turn-card").removeClass('card-active')
  if data.turn == 'blue'
    $(".red-turn-card").removeClass('card-active')
  animateCards()
  if data.status == 'checkmate'
    checkmated()

update_state = (player) ->
  $.ajax
    type: "GET"
    url: "/chess/game_state/#{window.id}"
    success: (data) ->
      updateCards(data)
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
      updateCards(data)
      setTimeout ->
        update_state(player)
      ,
        3000
      return false
    error: (data) ->
      console.log data
      return false


copySuccess = ->
  $('.clipboard').removeClass 'clipboard'
  $('.copied-back > img').css
    opacity: 1
  $('.link-card img').velocity
    rotateY: '180deg'
  ,
    duration: 1000
    easing: 'spring'
  $('.begin-card > img').css
    opacity: 1
  $('.begin-card2 > img').css
    opacity: 1
  $('.begin-card2 > img').velocity
    translateX: "-120px"
  ,
    duration: 1000
    easing: 'spring'
  $('.begin-card > img').velocity
    translateX: "120px"
  ,
    duration: 1000
    easing: 'spring'
  $('.begin-card > img').velocity
    translateY: "-10px"
  ,
    delay: 1000
    duration: 1000
    easing: 'spring'
  link = $('#begin-field').val()
  $('.begin-card').addClass 'begin-active'
  $('.begin-card > img ').addClass 'pointer'
  $('.begin-card > img').click ->
    $(@).removeClass 'pointer'
    $(@).unbind 'click mouseenter mouseleave'
    time = 0
    $('img').stop().each ->
      setTimeout =>
        $(@).velocity
          translateY: "-30px"
          opacity: 0.001
        ,
          duration: 1200
          easing: 'ease'
      ,
        time
      time += 40
    setTimeout ->
      window.location.href = link
    ,
      2000
  $('.copy-instructions').velocity
    opacity: 0
    translateY: '20px'
  ,
    delay: 500
    duration: 800
  $("#link-field").velocity
    opacity: 0
    translateY: '20px'
  ,
    delay: 500
    duration: 800
  $('.begin-card > img').hover ->
    $(@).stop().velocity
      scale: 1.05
    ,
      duration: 100
  , ->
    $(@).stop().velocity
      scale: 1
    ,
      duration: 200

$ ->

  if $('.pick-teams').size() > 0
    offsetx = $('.card-choose').offset().left
    count = 0

    $(".card-button").css
      opacity: 0
    $(".choose-team").velocity 'transition.slideUpIn',
      delay: 300
    $(".card-choose").addClass 'click-me'

    $(".click-me").on 'mouseenter', ->
      $(@).removeClass 'click-me'
      $(".card-choose").unbind 'mouseenter'
      $(".card-choose").velocity 'callout.shake'
      $(".front").velocity
        rotateY: "180deg"
      ,
        easing: 'spring'
        duration: 800
        delay: 2000
      $(".snack").velocity
        rotateY: "180deg"
      ,
        easing: 'spring'
        duration: 800
        delay: 2000
      $(".card-button").each ->
        factors = ["-",""]
        left = $(@).offset().left
        $(@).css
          opacity: 1
          left: "#{offsetx - left}px"
        $(@).velocity
          translateX: "#{(left - offsetx) / 4}px"
          rotateZ: "#{factors[count]}10deg"
        ,
          delay: 800
          duration: 700
          easing: 'spring'
        count += 1
        $(@).velocity
          translateX: "#{left - offsetx}px"
          rotateZ: "0deg"
        ,
          delay: 500
          duration: 800
          easing: 'spring'
        $('.card-button').addClass 'active-button'

      $('.active-button > img').hover ->
        $(@).stop().velocity
          scale: 1.05
        ,
          duration: 100
      , ->
        $(@).stop().velocity
          scale: 1
        ,
          duration: 200


    $(".card-button").on 'click touchstart', 'img', ->
      $('.link-card').removeClass 'violated'
      setTimeout ->
        unless $('.link-card').hasClass 'violated'
          $('.link-card > img').stop().velocity
            opacity: 0.5
          ,
            loop: 2
            duration: 300
      ,
        2500

      $('#link-field').on 'copy', copySuccess
      clipboard = new Clipboard('.clipboard')
      $('.clipboard').addClass 'clickboard'
      clipboard.on 'success', ->
        copySuccess()
      clipboard.on 'error', ->
        $('.link-card > img').stop().velocity
          scale: 1
        ,
          duration: 400
        $('.copy-instructions').velocity 'transition.slideDownIn'
        ,
          delay: 300
        $("#link-field").velocity 'transition.slideDownIn'
        $('.link-card > img').unbind 'mouseenter mouseleave'
      $('.card-button > img').unbind 'mouseenter mouseleave'
      $('.active-button').removeClass 'active-button'
      if $(@).hasClass 'select-red'
        chosen = 'red'
        $('.them-blue').velocity
          opacity: 1
          translateY: "160px"
        ,
          delay: 800
          duration: 800
          easing: 'spring'
        $('body').addClass 'red'
      else if $(@).hasClass 'select-blue'
        chosen = 'blue'
        $('.them-red').velocity
          translateY: "160px"
          opacity: 1
        ,
          delay: 800
          duration: 800
          easing: 'spring'
        $('body').addClass 'blue'
      $.ajax
        type: 'GET'
        url: "/chess/pick_#{chosen}"
        success: (data) ->
          $('#link-field').val data.sharelink
          $('#begin-field').val data.link
      $(@).parent(".card-button").addClass 'selected-team'
      $(".front").velocity
        rotateY: "0deg"
      ,
        delay: 100
        duration: 800
        easing: 'spring'
      $(".back").velocity
        rotateY: "0deg"
      ,
        delay: 100
        duration: 800
        easing: 'spring'
      $(@).parent('.card-button').addClass 'ahead'
      $(@).velocity
        scale: 1
        translateX: "#{(offsetx - $(@).parent('.card-button').offset().left)}px"
      ,
        duration: 800
        easing: 'spring'
      $(".card-button:not(.selected-team)").velocity
        translateX: "1px"
      ,
        duration: 800
        easing: 'spring'
      setTimeout ->
        $('.card-choose').velocity
          opacity: 0
        $(".card-button:not(.selected-team)").velocity
          opacity: 0
      ,
        600
      $('.link-card').velocity
        opacity: 1
        translateY: '160px'
      ,
        delay: 1000
        duration: 800
        easing: 'spring'
      $('.link-card > img').hover ->
        $('.link-card').addClass 'violated'
        $(@).stop().velocity
          scale: 1.05
        ,
          duration: 100
      , ->
        $(@).stop().velocity
          scale: 1
        ,
          duration: 400

  $('.back').velocity
    rotateY: "180deg"
  ,
    duration: 0
  if $("#board").size() > 0
    $('body').addClass 'red'

  $('.share-link').click (e)->
    e.preventDefault()
    e.stopPropagation()
    return false

  $('body').on 'click', '.active-modal', ->
    $('.cards-container').unbind 'click'
    $('#invite-modal').removeClass 'active-modal'
    $('.invite-box').velocity
      opacity: 0
      translateY: '-30px'

  $('.cards-container').hover ->
    if $('.idle-card').hasClass 'card-active'
      $(@).addClass('pointer')
      $(@).click ->
        $('#invite-modal').addClass 'active-modal'
        $('.invite-box').velocity 'transition.slideDownIn'
        $('.share-card > img').addClass('pointer')
        # $('.cards-container').mouseleave()

    $(@).addClass 'hovering'
    count = -2
    $('.idle-card > img').velocity
      rotateY: "180deg"
    ,
      duration: 200
    $('.back').velocity
      rotateY: "180deg"
    ,
      duration: 0
    $('.back').velocity
      rotateY: "0deg"
    ,
      duration: 200
    $('.back').css
      opacity: 1
    $('.cards').find('.card-active').each ->
      count += 1
      $(@).stop().velocity
        # opacity: 1
        translateX: "#{110 * count}px"
        rotateZ: "#{0 * count}deg"
      ,
        duration: 800
        easing: "spring"
    if count > -2
      count += 1
      $('.logo').stop().velocity
        translateX: "#{110 * count}px"
        rotateZ: "#{0 * count}deg"
      ,
        duration: 800
        easing: "spring"
  , ->
    $(@).removeClass('pointer')
    $(@).unbind 'click'
    $('.idle-card > img').stop().velocity
      rotateY: "0deg"
    ,
      duration: 200
    $('.back').stop().velocity
      rotateY: "180deg"
    ,
      duration: 200
    $(@).removeClass 'hovering'
    count = -2
    $('.cards').find('.card-active').each ->
      count += 1
      $(@).stop().velocity
        # opacity: 1
        translateX: "#{80 * count}px"
        rotateZ: "#{10 * count}deg"
      ,
        duration: 800
        easing: "spring"
    if count > -2
      count += 1
      $('.logo').stop().velocity
        translateX: "#{80 * count}px"
        rotateZ: "#{10 * count}deg"
      ,
        duration: 800
        easing: "spring"

  unless $('#board').hasClass('checkmate')
    $(".piece").css
      opacity: 0
    $(".stone").css
      opacity: 0
    $('#board').velocity "transition.slideUpIn"
    # setTimeout ->
    #   $(".piece").velocity 'transition.slideDownIn',
    #     stagger: 50
    #     drag: true
    # ,
    #   500
    setTimeout ->
      $(".stone").velocity 'transition.slideDownIn',
        stagger: 50
        drag: true
    ,
      1500

  window.id = $('#board').data('game-id')
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

  data = {red_active: true, blue_active: true, player: 'red'}

  $('td').css
    opacity: 0

  time = 1

  setTimeout ->
    $('td').each ->
      setTimeout =>
        $(@).velocity
          opacity: 1
      ,
        time
      time += 20
    $(".piece").velocity 'transition.slideDownIn',
      delay: 400
      stagger: 50
      drag: true
  ,
    500

  if $('#board').size() > 0
    setTimeout ->
      update_state(player)
    ,
      5000

  # alert player
  $(".#{player}-team-card").addClass('card-active')

  setTimeout ->
    updateCards(data)
  ,
    2000

  $('.cards-container').css
    opacity: 0
  $('.cards-container').velocity 'transition.slideUpIn',
    delay: 1000

  piece_selected = false
  piece = null

  # $(".audio-play")[0].currentTime = 0

  $('body').on 'click touchstart', 'td', ->
    unless piece_selected
      if player != window.turn
        $(".my-card.#{window.turn}-turn-card").addClass('card-active')
        animateCards()
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
      ,
        easing: [0.175, 0.885, 0.32, 1.175]
      $(".audio-play")[0].play()
      $('#move_to').val $(@).data('coord')

      setTimeout ->
        $.ajax
          type: "POST"
          url: "/chess/move/#{window.id}"
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
            updateCards(data)
            return false
          error: (data) ->
            console.log data
            return false
      ,
        100



