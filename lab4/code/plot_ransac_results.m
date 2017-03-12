function plot_ransac_results( left, right, f1, f2, W, T )

    figure, imshow([left right]); hold on
    vl_plotframe(f1); % left image
    vl_plotframe(f2); % right image

    ransac_keyspoints = W * f1(1:2,:)  + T + [size(left,2);0];
    plot([f1(1,:) ; ransac_keyspoints(1,:)], [f1(2,:) ; ransac_keyspoints(2,:)], 'y-')
    drawnow;
    title('RANSAC Results')
    hold off
    
end