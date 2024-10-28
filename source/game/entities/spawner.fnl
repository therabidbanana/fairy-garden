(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :spawner
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)

   fairy   (require :source.game.entities.fairy)]

  (fn react! [{:state { : timer : max-timer : tile-h : tile-w} &as self}]
    (let [new-t (- timer 1)]
      (if (<= new-t 0)
          (do
            (-> (fairy.new! self.x self.y { : tile-w : tile-h }) (: :add))
            (tset self.state :timer max-timer))
          (tset self.state :timer new-t))))

  (fn new! [x y {: tile-h : tile-w :layer-details { : grid-w : locations}}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          spawner (gfx.sprite.new)]
      (spawner:setCenter 0 0)
      (spawner:setBounds x y 32 32)
      (tset spawner :react! react!)
      (tset locations :spawner {: tile-x : tile-y})
      (tset spawner :state {:timer 100 :max-timer 100 : tile-h : tile-w})
      spawner)))
