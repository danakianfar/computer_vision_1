function applyflow(folder, ext, vfname, flow_N, K, sigma, threshold, harris_N)
    
    % Gets files in the folder
    files = dir(folder);
    
    outputVideo = VideoWriter(vfname);
    outputVideo.FrameRate = 24;
    open(outputVideo)
            
    for i = 1:length(files) 
        
        % Gets the name of the current file
        fname = files(i).name;
        
        % Checks if the file has te correct extension
        jp_pos = strfind(fname, ext);
        
        if ~isempty(jp_pos)
            
            fprintf('Processing Image: %s\n',fname);
            
            % Read current frame
            image1 = imread(strcat(folder, fname));
            
            % If looking at the last file, just show image and break
            if i == length(files)
                imshow(image1);
                break
            end
            
            % Read following frame
            image2 = imread(strcat(folder, files(i+1).name));
            
            % Find features using the Harris corner detector
            [ ~, X, Y, ~, ~] = harris(rgb2gray(im2double(image1)), K, sigma, threshold, harris_N);
            
            % Apply optical flow to im1 im2
            [ U, V ] = opticalflow(image1, image2, X, Y, flow_N, K, sigma);
            
            % Display current frame
            imshow(image1);
            hold on
            
            % Plot vectors
            quiver(X, Y, U, V, 0, 'b');
            frame = getframe;
            hold off
            
            writeVideo(outputVideo,frame);

        end
    end
    
    close(outputVideo)
    fprintf('Video successfully generated at %s\n',vfname);
    
end

