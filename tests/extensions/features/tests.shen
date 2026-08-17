(load "extensions/features.shen")

(destroy shen.x.features.initialise)
(destroy shen.x.features.current)
(destroy shen.x.features.add)
(shen.x.features.initialise [feature-a])

(extension-tests.assert-equal
  "features initialise has a type"
  (shen.typecheck
    [shen.x.features.initialise [cons feature-a []]]
    [list symbol])
  [list symbol])

(extension-tests.assert-equal
  "features current has a type"
  (shen.typecheck
    [shen.x.features.current]
    [list symbol])
  [list symbol])

(extension-tests.assert-equal
  "features add has a type"
  (shen.typecheck
    [shen.x.features.add feature-b]
    [list symbol])
  [list symbol])

(extension-tests.assert-equal
  "features initialise updates the feature list"
  (shen.x.features.current)
  [feature-a])

(extension-tests.assert-equal
  "features add returns the previous feature list"
  (shen.x.features.add feature-b)
  [feature-a])

(extension-tests.assert-equal
  "features add updates the feature list"
  (shen.x.features.current)
  [feature-b feature-a])
