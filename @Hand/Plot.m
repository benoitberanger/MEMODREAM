function Plot( obj )

figure
image(obj.imgFinal(:,:,1:3)) % no alpha blending
axis equal % pixels are isometrics

end
