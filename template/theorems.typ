#import "numbering.typ": *

#let mathcounter = counter("mathblock")
#let chaptercounter = counter(heading)

#let theorem = figure.with(kind: "theorem", supplement: "定理")
#let lemma = figure.with(kind: "theorem", supplement: "引理")
#let proof = figure.with(kind: "proof", supplement: "证明")
#let qed = sym.square
