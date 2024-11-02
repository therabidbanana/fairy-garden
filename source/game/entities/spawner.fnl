(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :spawner
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile          (require :source.lib.behaviors.tile-movement)
   $ui           (require :source.lib.ui)

   fairy   (require :source.game.entities.fairy)]

  (fn react! [{:state { : timer : max-timer : tile-h : tile-w : waves : curr-wave} &as self}]
    (let [wave (?. waves curr-wave)
          curr-wave-count (?. wave :released)
          new-count (+ (or curr-wave-count 0) 1)
          new-countup (+ (or (?. wave :countup) 0) 1)
          new-t (- timer 1)]
      (if (= wave nil)
          nil
          (< new-countup wave.countdown)
          (tset wave :countup new-countup)
          (and (<= new-count wave.count) (<= new-t 0))
          (do
            (-> (fairy.new! self.x self.y { : tile-w : tile-h }) (: :add))
            (tset self.state :timer wave.delay)
            (tset wave :released new-count)
            (when (>= new-count wave.count)
              (tset self.state :curr-wave (+ curr-wave 1))
              )
            )
          (tset self.state :timer new-t))))

  (fn parse-wave [{: wave_countdowns : wave_counts : wave_delays}]
    (let [waves (icollect [i v (ipairs wave_counts)]
                  {:released 0 :count v
                   :delay (?. wave_delays i)
                   :countup 0
                   :countdown (or (?. wave_countdowns i) 300)})]
      waves))

  (fn new! [x y {: tile-h : tile-w : fields :layer-details { : grid-w : locations : wave-details}}]
    (let [tile-x (div x tile-w)
          tile-y (div y tile-h)
          spawner (gfx.sprite.new)]
      (spawner:setCenter 0 0)
      (spawner:setBounds x y 32 32)
      (inspect (parse-wave wave-details))
      (tset spawner :react! react!)
      (tset spawner :spawner? true)
      (tset spawner :fields fields)
      (tset locations :spawner {: tile-x : tile-y})
      (tset spawner :state {:timer 100 :max-timer 100
                            :waves (parse-wave wave-details)
                            :curr-wave 1
                            : tile-h : tile-w})
      spawner)))
