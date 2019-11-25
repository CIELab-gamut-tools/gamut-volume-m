function [map] = map_rows(ref, targ)

%MAP_ROWS map the rows of a reference matrix to a target matrix
%  map = map_rows(ref, target) returns a column vector which is a map of
%  where in the target matrix each reference row can be found.

map = zeros(size(ref,1),1);
for m=1:size(ref,1)
    [~,IX]=ismember(ref(m,:),targ,'rows');
    map(m)=IX;
end
