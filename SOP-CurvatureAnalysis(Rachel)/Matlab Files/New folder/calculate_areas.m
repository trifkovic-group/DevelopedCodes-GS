function [ areas ] = calculate_areas( faces, vertices )

areas = zeros(length(faces),1);

for i = 1:length(faces)
   p1 = vertices(faces(i,1),:);
   p2 = vertices(faces(i,2),:);
   p3 = vertices(faces(i,3),:);
   
   v = cross(p1-p2,p1-p3);
   areas(i,1) = norm(v)/2;
end

end

