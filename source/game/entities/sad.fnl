(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :redirect
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   life-bar      (require :source.game.entities.life_bar)
   $ui           (require :source.lib.ui)]

  (fn interacted! [{:state { : dir } &as self} fairy]
    (case dir
      :up (tset self :state :dir :down)
      :down (tset self :state :dir :up)
      :left (tset self :state :dir :right)
      :right (tset self :state :dir :left)
      _ nil)
    {:add-happiness -1})

  (fn player-interact! [{:state { : dir : water : hp} &as self} primary?]
    (if (and (not primary?) (<= hp 1))
        (do
          (self.life-bar:remove)
          (self:remove))
        (not primary?)
        (tset self :state :hp (- hp 1)))
    )

  (fn react! [{:state { : dir : tile-h : tile-w} &as self}])

  (fn collisionResponse [self other]
    :overlap)

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          dir (or (?. fields :dir) :right)
          image (gfx.imagetable.new :assets/images/weed)
          redirect (gfx.sprite.new)
          hp 8
          ]
      (redirect:setCenter 0 0)
      (redirect:setImage (image:getImage 1))
      (redirect:setBounds x y 32 32)
      (redirect:setCollideRect 0 0 32 32)
      (redirect:setGroups [4])
      (redirect:setCollidesWithGroups [3])
      (tset redirect :life-bar (life-bar.new! x y {:linked redirect :curr 8 :field :hp}))
      (tset redirect :react! react!)
      (tset redirect :interacted! interacted!)
      (tset redirect :player-interact! player-interact!)
      (tset redirect :collisionResponse collisionResponse)
      (tset redirect :state {: dir : tile-h : tile-w : hp})
      redirect)))
