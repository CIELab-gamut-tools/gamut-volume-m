function [TRI_ref, RGB_ref] = make_tesselation(gsv)
%MAKE_TESSELATION create an RGB gamut surface tesselation
%  [TRI, RGB] = make_tesselation(values) will construct a reference RGB
%  tesselation from a unique set of the given greyscale values.

N = length(gsv);
%build the reference RGB table
[J,K]=meshgrid(gsv,gsv);
J=J(:); K=K(:);
Lower=zeros(size(J)); Upper=Lower+gsv(end);
%on the bottom surface the order must be rotations of Lower,J,K
%on the top surface the order must be rotations of Upper,K,J 
RGB_ref=[Lower, J, K; K, Lower, J; J, K, Lower;...
     Upper, K, J; J, Upper, K; K, J, Upper];

%build the required tessellation
TRI_ref=zeros(12*(N-1)^2,3);
idx=1;
for s=1:6
    for q=1:N-1
        for p=1:N-1
            m=N^2*(s-1) + N*(q-1) + p;
            %The two triangles must have the same rotation
            %consider A B  triangle 1 = A-B-C
            %         C D  triangle 2 = B-D-C
            %both are clockwise
            TRI_ref(idx,:)=[m, m+N, m+1];
            TRI_ref(idx+1,:)=[m+N, m+N+1, m+1];
            idx=idx+2;
       end
    end
end
