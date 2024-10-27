(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :tree
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   ]

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w :layer-details {: node-list : grid-w : locations}}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)]
      (tset node-list (+ (* tile-y grid-w) (+ tile-x 1)) 1)
      (tset locations :tree {: tile-x : tile-y})
      nil)))
