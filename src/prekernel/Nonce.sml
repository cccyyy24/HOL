structure Nonce :> Nonce =
struct

  type 'a t = 'a ref
  fun mk v = ref v
  fun dest r = !r

end
