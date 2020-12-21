function d=sRGBgamma(v)
    d=25*v/323;
    sel=v>0.04045;
    d(sel)=((200*v(sel)+11)/211).^2.4;
end

