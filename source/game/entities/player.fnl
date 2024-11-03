(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   justpressed? playdate.buttonJustPressed
   gfx playdate.graphics
   $ui (require :source.lib.ui)
   tile (require :source.lib.behaviors.tile-movement)
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)
   splitter   (require :source.game.entities.splitter)
   sprinkler   (require :source.game.entities.sprinkler)
   redirect   (require :source.game.entities.redirect)
   happy   (require :source.game.entities.happy)
   $particles           (require :source.game.particles)
   ]

  (fn purchase-and-place! [{ :tile-movement-opts { : tile-w : tile-h } &as self} item]
    (let [ideal-x (* (div self.x tile-w) tile-w)
          ideal-y (* (div self.y tile-h) tile-h)
          class (case item
                 {:type :redirect : dir} redirect
                 {:type :splitter : dir} splitter
                 {:type :sprinkler} sprinkler
                 {:type :tulip} happy
                 )
          cost class.cost
          new-cash (- self.state.cash cost)]
      (when (>= new-cash 0)
        (->
         (class.new! ideal-x ideal-y { :fields item : tile-w : tile-h })
         (: :add))
        (tset self.state :cash new-cash)
        (tset self.state :chosen-item nil)
        )
      )
    )

  (fn choose-item! [self item]
    (tset self.state :chosen-item item)
    )

  (fn shop! [self]
    (self:->stop!)
    ($ui:open-menu! {:can-exit? true
                     :options [
                               {:text (.. "(" redirect.cost ") " "Redirect")
                                :action #(self:choose-item! {:type :redirect :dir :left})}
                               {:text (.. "(" sprinkler.cost ") " "Sprinkler")
                                :action #(self:choose-item! {:type :sprinkler})}
                               {:text (.. "(" splitter.cost ") " "Splitter")
                                :action #(self:choose-item! {:type :splitter :dir :left})}
                               {:text (.. "(" happy.cost ") " "Tulip")
                                :action #(self:choose-item! {:type :tulip})}
                               ]})
    )

  (fn react! [{: state : height : x : y : width &as self} $scene]
    (when (= nil state.chosen-item)
      (if (justpressed? playdate.kButtonLeft) (self:->left!)
          (justpressed? playdate.kButtonRight) (self:->right!)
          (justpressed? playdate.kButtonUp) (self:->up!)
          (justpressed? playdate.kButtonDown) (self:->down!)))
    (when state.chosen-item
      (if (justpressed? playdate.kButtonLeft) (if (?. state.chosen-item :dir) (tset state.chosen-item :dir :left))
          (justpressed? playdate.kButtonRight) (if (?. state.chosen-item :dir) (tset state.chosen-item :dir :right))
          (justpressed? playdate.kButtonUp) (if (?. state.chosen-item :dir) (tset state.chosen-item :dir :up))
          (justpressed? playdate.kButtonDown) (if (?. state.chosen-item :dir) (tset state.chosen-item :dir :down))))
    (let [(dx dy) (self:tile-movement-react! state.speed)
          dx (if (and (>= (+ x width) $scene.state.stage-width) (> dx 0)) 0
                 (and (<= x 0) (< dx 0)) 0
                 dx)
          dy (if (and (>= (+ y height) $scene.state.stage-height) (> dy 0)) 0
                 (and (<= y 0) (< dy 0)) 0
                 dy)
          sprites-at (gfx.sprite.querySpritesAtPoint (+ x 1) (+ y 1))
          overlapping (?. (icollect [i v (ipairs sprites-at)]
                            (if (?. v :player?) nil v))
                          1)
          clear-square (= nil overlapping)
          ]
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))

      ;; (if (playdate.buttonJustPressed playdate.kButtonB)
      ;;     (scene-manager:select! :menu))
      (if
       (and (playdate.buttonJustPressed playdate.kButtonB)
            state.chosen-item)
       (tset state :chosen-item nil)
       (and (playdate.buttonJustPressed playdate.kButtonB)
            (?. overlapping :player-interact!))
       (overlapping:player-interact! false)
       (and (playdate.buttonJustPressed playdate.kButtonB)
            (?. overlapping :water!))
       (do
         ($particles.splash! self.x self.y)
         (overlapping:water! 1)))
      (if
       (and (playdate.buttonJustPressed playdate.kButtonA)
            state.chosen-item)
       (self:purchase-and-place! state.chosen-item)
       (and (playdate.buttonJustPressed playdate.kButtonA)
            (?. overlapping :player-interact!))
       (overlapping:player-interact! true)
          (and (playdate.buttonJustPressed playdate.kButtonA)
               clear-square)
          (self:shop!))
      )
    self)

  (fn update [{:state {: item-table : animation : dx : dy : walking?} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (tset self :state :even-tick (not (or self.state.even-tick false)))
      (if self.state.chosen-item
          (self:setImage (: (?. item-table self.state.chosen-item.type) :getImage
                            (case (or self.state.chosen-item.dir :left)
                              :left 1 :up 2 :right 3 :down 4)))
          (self:setImage (animation:getImage)))
      (if (and self.state.chosen-item self.state.even-tick)
          (self:setVisible false)
          (self:setVisible true)
          )
      (self:markDirty))
    )

  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   ;; (love.graphics.rectangle "fill" x y w h)
  ;;   (animation:draw x y)
  ;;   )

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-w : tile-h : fields}]
    (let [image (gfx.imagetable.new :assets/images/player-sprite)
          animation (anim.new {: image :states [{:state :walking :start 1 :end 4}]})
          player (gfx.sprite.new)
          cash  (or (?. fields cash) 10)
          item-table
          {:tulip (gfx.imagetable.new :assets/images/tulip)
           :redirect (gfx.imagetable.new :assets/images/redirect)
           :splitter (gfx.imagetable.new :assets/images/splitter)
           :sprinkler (gfx.imagetable.new :assets/images/sprinkler)
           }
          ]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      (player:setCollideRect 0 0 32 32)
      (player:setGroups [1])
      (player:setCollidesWithGroups [])
      (player:setZIndex 12)
      ;; (tset player :draw draw)
      (tset player :player? true)
      (tset player :update update)
      ;; (tset player :collisionResponse collisionResponse)
      (tset player :react! react!)
      (tset player :purchase-and-place! purchase-and-place!)
      (tset player :shop! shop!)
      (tset player :choose-item! choose-item!)
      (tset player :state {: cash : item-table : animation :speed 6 :dx 0 :dy 0 :visible true})
      (tile.add! player {: tile-h : tile-w})
      player)))

