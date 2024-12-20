(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(pd/import :CoreLibs/animation)
(pd/import :CoreLibs/easing)
(pd/import :CoreLibs/animator)

(let [gfx playdate.graphics
      animation  gfx.animation
      sprite gfx.sprite]

  (fn add-scene! [$ name scene]
    (doto $ (tset :scenes name scene)))

  (fn load-scenes! [{: scenes &as $} table game-state]
    (tset $ :scenes table)
    (tset $ :game-state (or game-state {}))
    $)

  (fn reset-state! [{: scenes &as $} game-state]
    (tset $ :game-state (or game-state {}))
    $)

  (fn exit-scene! [$ scene]
    (tset $ :last-screen (gfx.getDisplayImage))
    (tset $ :fade-out-anim (playdate.graphics.animator.new 300 0 -400 playdate.easingFunctions.outCubic))
    (gfx.clear)
    (sprite.removeAll)
    (if (and scene (?. scene :exit!)) (scene:exit! $.game-state))
    )

  (fn select! [{: active : scenes &as $} name]
    (tset $ :new-scene name))

  (fn tick! [{: active : new-scene : scenes &as $}]
    (when (not= new-scene nil)
      (if active ($:exit-scene! active))
      (tset $ :active (?. scenes new-scene))
      (tset $ :new-scene nil)
      ($.active:enter! $.game-state))
    (if (and $.active (?. $.active :tick!)) ($.active:tick! $.game-state))
    (playdate.timer.updateTimers)
    (animation.blinker.updateAll)
    )

  (fn transition-draw! [{: active : fade-out-anim : last-screen &as $}]
    (if (and active (?. active :transition-draw!)) (active:transition-draw!))
    (if (and fade-out-anim (fade-out-anim:ended))
        (do
          (tset $ :fade-out-anim nil)
          (tset $ :last-screen nil))
        (and fade-out-anim last-screen)
        ;; Transition by sliding left
        (do
          (gfx.clear)
          (last-screen:drawIgnoringOffset (fade-out-anim:currentValue) 0))
        )
    )

  (fn draw! [{: active : fade-out-anim : last-screen &as $}]
    (sprite.update)
    (if $config.debug (playdate.drawFPS 380 20))
    (if (and active (?. active :draw!)) (active:draw! $.game-state))
    )

  (fn debug-draw! [{: active : fade-out-anim : last-screen &as $}]
    (if (and $config.debug active (?. active :debug-draw!)) (active:debug-draw!))
    )

  {: add-scene!
   : load-scenes!
   : exit-scene!
   : select!
   : draw!
   : debug-draw!
   : transition-draw!
   : reset-state!
   : tick!
   :scenes {}})

