function cylmap = cielab_cylindrical_map(gamut)
TRI = gamut.TRI;
LAB = gamut.LAB;
Lsteps = gamut.Lsteps;
hsteps = gamut.hsteps;
Z=LAB(:,[2 3 1]);
%Find the minmum and maxmum L* in each triangle

Max_L=max(max(Z(TRI(:,1),3),Z(TRI(:,2),3)),Z(TRI(:,3),3));
Min_L=min(min(Z(TRI(:,1),3),Z(TRI(:,2),3)),Z(TRI(:,3),3));

%Define L* and Hue intervals for integrating the tesselated surace to obtain its volume

delta_Hue=2*pi/hsteps;

L=(0:100/Lsteps:100)';
Hue=(0:delta_Hue:2*pi)';

cylmap=cell(Lsteps,hsteps);

%For every step in L*
for p=2:size(L,1)
    
    Lmid=(L(p)+L(p-1))/2;
    orig=[0 0 Lmid];

    IX=find(Lmid>=Min_L&Lmid<=Max_L);
	orig=repmat(orig,size(IX));
    vert0=Z(TRI(IX,1),:);
    vert1=Z(TRI(IX,2),:);
    vert2=Z(TRI(IX,3),:);
    
    % find vectors for two edges sharing vert0
    edge1 = vert1-vert0;    
    edge2 = vert2-vert0;
    % and the vector to the origin
    o  = orig -vert0;       
    % pre-calculate the cross products outside the inner loop
    e2e1 = cross(edge2, edge1, 2);
    e2o = cross(edge2, o, 2);
    oe1 = cross(o, edge1, 2);
    % and the one determinant which does not involve 'dir'
    e2oe1 = sum(edge2.*oe1, 2);
    % drop the L* coordinate as the 'dir' vector always has dL*=0
    e2e1=e2e1(:,1:2);
    e2o=e2o(:,1:2);
    oe1=oe1(:,1:2);
    
    %for every step in Hue
    for q=2:size(Hue,1)

        %the unit vector represented by L* and Hue (just the da*,db* terms)
        Hmid=(Hue(q)+Hue(q-1))/2;
        dir=[sin(Hmid);cos(Hmid)]; 
        
        idet   = 1./(e2e1*dir); % denominator for all calculations
        u    = e2o*dir.*idet;   % 1st barycentric coordinate
        v    = oe1*dir.*idet;   % 2nd barycentric coordinate
        t    = e2oe1.*idet;     % 'position on the line' coordinate

        %Find the tiles for which the ray passes within their edges
        %The triangle perimiter is defined by edges u=0, v=0 and u+v=1
        %plus the addition of a tolerance to deal with round-off errors
        ix= u>=0 & v>=0 & u+v<=1 & t>=0;
        %If no tile was found, add some tolerance and try again.
        if (sum(ix)==0)
            ix= u>=-0.001 & v>=-0.001& u+v<=1.001 & t>=0;
        end
        % sort the intersections
        cm = [sign(idet(ix)),t(ix)];
        [~,idx] = sort(cm(:,2));
        cm = cm(idx,:);
        % check for a common surface parity error
        cm = cm(flip(cumsum(flip(cm(:,1))))*2-cm(:,1)==1,:);
        cylmap{p-1,q-1}=cm;
    end                 
end