subroutine cquad(a,b,c,nq,x,quad)
  implicit none
  integer, intent(in)  ::nq
  real,    intent(in)  ::a,b,c,x(nq)
  real,    intent(out) ::quad(nq)
  integer              ::i

  quad = a*x**2+b*x+c
  return
end subroutine cquad