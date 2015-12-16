function [feature] = copymove( im,b )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
[m,n,d]=size(im);
if d>1
    im=rgb2gray(im);
end
feature=zeros(m-b+1*n-b+1,17);
index_x=1;
for i=1:1:m-b+1
    for j=1:1:n-b+1
        block=im(i:i+b-1,j:j+b-1);
        a=hash_func(block);
        for index_y=1:1:15
            feature(index_x,index_y)=a(index_y);
        end
        feature(index_x,16)=i;
        feature(index_x,17)=j;
        index_x=index_x+1;
    end
end
feature=sortrows(feature,1:15);
feature=feature(:,1:15);
loc=feature(:,16:17);
[numberOfRows,numberOfColumns]=size(feature);
shift_vector=(numberOfRows,2);
match1=(numberOfRows,2);
match2=(numberOfRows,2);
num_match_index=1;
for current=1:1:numberOfRows-1                                              % no of comparisons
    next=current+1;
    d=sum(abs(feature(current)-feature(next)))/1023;              % distance for matching blocks
    if d<.05                                                      % for matching blocks extract the coordinates
        x1y1=loc(current,:);
        x2y2=loc(next,:);
        shift_vector(num_match_index,:) = [abs(x1y1(1) - x2y2(1)), abs(x1y1(2) - x2y2(2))]; % compute the shift vector
        if ~isequal(shift_vector(num_match_index,:), [0,1]) && ...
                ~isequal(shift_vector(num_match_index,:), [1,0]) && ...
                ~isequal(shift_vector(num_match_index,:), [1,1])
            match1(num_match_index,:)=x1y1;
            match2(num_match_index,:)=x2y2;
            num_match_index=num_match_index+1;
        end
    end
end
match1 = match1(1:num_match_index, :);                              %downsizing
match2 = match2(1:num_match_index, :);
shift_vector = shift_vector(1:num_match_index, :);
    
end

