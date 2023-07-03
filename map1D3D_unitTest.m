maxx = 50;
maxy = 10;
err = 0;
tuttelen = zeros(999,1);
i = 1;
for x = 1:maxx
    for y = 1:maxy
        for z = 1:10
            n = map3DTo1D(x,y,z,maxx,maxy);
            [x_, y_, z_] = map1DTo3D(n,maxx,maxy);
            disp('tripla:')
            disp([x y z])
            disp('n:')
            disp(n)
            disp('remap')
            disp([x_, y_, z_])
            disp('----------')
            if (n < 0) || (x ~= x_) || (y ~= y_) || (z ~= z_)
                err = 1;
            end
            if (find(tuttelen == n) ~= 0)
                err = 1;
            end
            tuttelen(i) = n;
            i = i+1;
            
        end
    end
end