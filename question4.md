Note: I`m using ~ as Not()
Every cruise ship was accompanied by at least one tug.
∀s IsCruiseShip(s) -> ∃t IsTug(t) ^ Accompanied(t, s)

At least one tanker was accompanied by more than one tug.
∃t ∃x ∃y IsTanker(t) ^ IsTug(x) ^ IsTug(y) ^ Accompanied(x, t) ^ Accompanied(y, t) ^ ~(x=y)

All the fishing boats but one returned safely to port.  <-> exactly one fishing boat did not return safetly to port
∃b ∀x ~ReturnedSafetly(x) <-> (x = b)

There are exactly two students with grade less than B.
∃x ∃y ∀s GradeIsB(s) <-> ((s=x) v (s=y)) ^ ~(x=y)
