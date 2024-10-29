(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :spawner
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)

   fairy   (require :source.game.entities.fairy)]

  (fn react! [{:state { : timer : max-timer : tile-h : tile-w : waves} &as self}]
    (let [curr-wave (?. waves 1)
          curr-wave-count (?. curr-wave :count)
          new-count (- (or curr-wave-count 1) 1)
          new-t (- timer 1)]
      (if (= curr-wave nil)
          nil
          (and (>= curr-wave-count 1) (<= new-t 0))
          (do
            (-> (fairy.new! self.x self.y { : tile-w : tile-h }) (: :add))
            (tset self.state :timer curr-wave.delay)
            (tset self.state :waves 1 :count new-count)
            (when (= new-count 0)
              (tset self.state :waves (table.remove waves 1)))
            )
          (tset self.state :timer new-t))))

  (fn parse-wave [{: wave_counts : wave_delays}]
    (let [waves (icollect [i v (ipairs wave_counts)]
                  {:count v :delay (?. wave_delays i)})]
      waves))

  (fn new! [x y {: tile-h : tile-w :layer-details { : grid-w : locations : wave-details}}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          spawner (gfx.sprite.new)]
      (spawner:setCenter 0 0)
      (spawner:setBounds x y 32 32)
      (inspect (parse-wave wave-details))
      (tset spawner :react! react!)
      (tset spawner :spawner? true)
      (tset locations :spawner {: tile-x : tile-y})
      (tset spawner :state {:timer 100 :max-timer 100
                            :waves (parse-wave wave-details)
                            : tile-h : tile-w})
      spawner)))
