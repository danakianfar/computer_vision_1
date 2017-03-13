function Z = interpolate(Z, candidates_x, candidates_y,corners, interp_fun, nn_window, zerofill)

    % filter candidates for those inside the boundary
    [interp_candidates] = inpoly([candidates_x, candidates_y], corners');
    
    % replace assigned variables by interpolation, or zero if outside image
    for c=1:size(Z,3) % for all channels
        for i=1:numel(interp_candidates)
            x = candidates_x(i); y = candidates_y(i); % candidate coordinates
            
            if interp_candidates(i) % if within the image (polygon)
                
                window = Z(max(1,x-nn_window):min(size(Z,1),x+nn_window), ...
                    max(1,y-nn_window):min(size(Z,2),y+nn_window), c); % 3x3 window centered on candidates excluding edges
                window = window(:);
                window = window(window >= 0); % exclude center
                Z(x,y,c) = interp_fun(window); % interpolate (mean or median)
            else 
                if zerofill
                    Z(x,y,c) = 0;
                end
            end
        end
    end

end