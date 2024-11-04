(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :life_bar
  [gfx playdate.graphics
   ]

  (fn frame-for [curr max]
    (clamp 1 (div (/ curr (/ max 8)) 1) 8))

  (fn react! [{:state { : image : curr : linked : field : max-val} &as self}]
    (let [new-val (?. linked :state field)
          max-val (or max-val 8)
          frame (frame-for new-val max-val)]
      (self:setVisible (not= new-val max-val))
      (when (not= new-val curr)
        (tset self :state :curr new-val)
        (self:setImage (image:getImage frame)))
      (when (or (not= self.x linked.x) (not= self.y linked.y))
        (self:moveTo linked.x linked.y))))

  (fn new! [x y {: linked : field : curr : max-val}]
    (let [field (or field :water)
          image (gfx.imagetable.new :assets/images/life-bar)
          water-bar (gfx.sprite.new)
          max-val (or max-val curr 8)
          curr-frame (frame-for (or curr 8) max-val)]
      (water-bar:setCenter 0 0)
      (water-bar:setImage (image:getImage curr-frame))
      (water-bar:setBounds x y 32 8)
      (water-bar:setZIndex 9)
      (tset water-bar :react! react!)
      (tset water-bar :state {: linked : curr : max-val : image : field})
      water-bar)))
