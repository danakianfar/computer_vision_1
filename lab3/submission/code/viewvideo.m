function viewvideo( fname )

    shuttleAvi = VideoReader(fname);

    ii = 1;
    while hasFrame(shuttleAvi)
       mov(ii) = im2frame(readFrame(shuttleAvi));
       ii = ii+1;
    end

    f = figure;
    f.Position = [150 150 shuttleAvi.Width shuttleAvi.Height];

    ax = gca;
    ax.Units = 'pixels';
    ax.Position = [0 0 shuttleAvi.Width shuttleAvi.Height];

    image(mov(1).cdata,'Parent',ax)
    axis off

    movie(mov,1,shuttleAvi.FrameRate)

end

