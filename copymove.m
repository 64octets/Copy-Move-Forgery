function [feature] = copymove( im,b )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
[m,n,d]=size(im);
if d>1
    im=rgb2gray(im);
end
feature=[];
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
feature=sortrows(feature);
[numberOfRows,numberOfColumns]=size(feature);
matchingBlocks=1;
previousShift=0;
for current=1:1:numberOfRows-1                                              % no of comparisons
    next=current+1;
    d=sum(abs(feature(current,1:15)-feature(next,1:15)))/1023;              % distance for matching blocks
    if d<.05
        shift=sqrt(sum((feature(current,16:17)-feature(next,16:17)).^2));   % if blocks are matching
        if abs(previousShift-shift)<1
            matchingBlocks=matchingBlocks+1;
        end
        previousShift=shift;
    end
end
if matchingBlocks>8
    
end

