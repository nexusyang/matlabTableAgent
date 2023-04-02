function y=transTableFunc(t)
    temp=circshift(t,1);
    temp=[NaN;temp(2:end)];
    y=(t-temp)./temp;
end