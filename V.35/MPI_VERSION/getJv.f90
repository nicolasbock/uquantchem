SUBROUTINE getJv(P,NB,NRED,Istart,Iend,Intsv,IND1,IND2,IND3,IND4,numprocessors,id,Jout)
      IMPLICIT NONE
      INCLUDE "mpif.h"
      INTEGER, INTENT(IN) :: NB,numprocessors,id
      INTEGER*8, INTENT(IN) :: Istart,Iend,NRED
      INTEGER, INTENT(IN) :: IND1(Istart:Iend),IND2(Istart:Iend),IND3(Istart:Iend),IND4(Istart:Iend)
      DOUBLE PRECISION, INTENT(IN) :: P(NB,NB),Intsv(Istart:Iend)
      DOUBLE PRECISION, INTENT(OUT) :: Jout(NB,NB)
      INTEGER*8 :: I,J,N,M,MM,K,L,G,ierr,displs(numprocessors),rcounts(numprocessors)
      INTEGER, EXTERNAL :: ijkl
      DOUBLE PRECISION :: Jsend(NB,NB),Jrecieve(numprocessors),fact1,fact2
      
 
      Jout = 0.0d0
      Jsend = 0.0d0
      Jrecieve = 0.0d0

      DO I=1,numprocessors
          displs(I) = I-1
          rcounts = 1
      ENDDO

      DO G=Istart,Iend
                I = IND1(G)
                J = IND2(G)
                K = IND3(G)
                L = IND4(G)
                fact1 = 1.0d0
                IF ( K .NE. L ) fact1 = 2.0d0
                Jsend(I,J) = Jsend(I,J) + fact1*Intsv(G)*P(K,L)
                IF ( I .NE. J ) Jsend(J,I) = Jsend(I,J)
      ENDDO
      
       CALL MPI_REDUCE(Jsend,Jout,NB*NB,MPI_DOUBLE_PRECISION,MPI_SUM,0,MPI_COMM_WORLD, ierr)
       CALL MPI_BCAST(Jout,NB*NB,MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr)
       CALL MPI_BARRIER(MPI_COMM_WORLD,ierr)
END SUBROUTINE getJv