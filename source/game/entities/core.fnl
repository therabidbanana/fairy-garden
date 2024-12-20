(let [player   (require :source.game.entities.player)
      fairy    (require :source.game.entities.fairy)
      tree     (require :source.game.entities.tree)
      spawner  (require :source.game.entities.spawner)
      redirect  (require :source.game.entities.redirect)
      splitter  (require :source.game.entities.splitter)
      happy  (require :source.game.entities.happy)
      statue  (require :source.game.entities.statue)
      animal_statue  (require :source.game.entities.animal_statue)
      marigold  (require :source.game.entities.marigold)
      sad  (require :source.game.entities.sad)
      sprinkler  (require :source.game.entities.sprinkler)

      tree-hud (require :source.game.entities.tree_hud)
      hud (require :source.game.entities.hud)
      chosen-item (require :source.game.entities.chosen-item)

      map-selector (require :source.game.entities.map_selector)
      warp (require :source.game.entities.warp)
      ]
  {: player  : fairy : tree : spawner : redirect : splitter : sad
   : sprinkler

   : marigold : happy : statue : animal_statue

   : tree-hud : hud : chosen-item

   : map-selector : warp})
