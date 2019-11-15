%%
%Implementation based on:
%Xiao Han, Kai Niu and Zhiqiang He, "Implementation of IEEE 802.11n LDPC codes based on general purpose processors,"
%2013 15th IEEE International Conference on Communication Technology, Guilin, 2013, pp. 218-222.
%doi: 10.1109/ICCT.2013.6820375
%%


function H = parityMatrixBuilder( rate )

    Z=54;
    H_1296_1_2 =[40 -1 -1 -1 22 -1 49 23 43 -1 -1 -1 1 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1;
                50 1 -1 -1 48 35 -1 -1 13 -1 30 -1 -1 0 0 -1 -1 -1 -1 -1 -1 -1 -1 -1;
                39 50 -1 -1 4 -1 2 -1 -1 -1 -1 49 -1 -1 0 0 -1 -1 -1 -1 -1 -1 -1 -1;
                33 -1 -1 38 37 -1 -1 4 1 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1 -1 -1;
                45 -1 -1 -1 0 22 -1 -1 20 42 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1 -1;
                51 -1 -1 48 35 -1 -1 -1 44 -1 18 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1;
                47 11 -1 -1 -1 17 -1 -1 51 -1 -1 -1 0 -1 -1 -1 -1 -1 0 0 -1 -1 -1 -1;
                5 -1 25 -1 6 -1 45 -1 13 40 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1;
                33 -1 -1 34 24 -1 -1 -1 23 -1 -1 46 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1;
                1 -1 27 -1 1 -1 -1 -1 38 -1 44 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1;
                -1 18 -1 -1 23 -1 -1 8 0 35 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0;
                49 -1 17 -1 30 -1 -1 -1 34 -1 -1 19 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 0];    

     H_1296_5_6 = [48 29 37 52 2 16 6 14 53 31 34 5 18 42 53 31 45 -1 46 52 1 0 -1 -1;
                17 4 30 7 43 11 24 6 14 21 6 39 17 40 47 7 15 41 19 -1 -1 0 0 -1;
                7 2 51 31 46 23 16 11 53 40 10 7 46 53 33 35 -1 25 35 38 0 -1 0 0;
                19 48 41 1 10 7 36 47 5 29 52 52 31 10 26 6 3 2 -1 51 1 -1 -1 0 ];
            
      circ_mat_array = {};
            for i = 0 : Z - 1
                circ_mat = zeros(Z,Z);
                for j = 0 : Z - 1
                    circ_mat(j + 1, mod(j + i, Z) + 1) = 1;
                end
                circ_mat_array{i + 1} = circ_mat;
            end
            obj.N = Z *  size(baseH, 2);
            obj.M = Z *  size(baseH, 1);
            obj.K = obj.N - obj.M;
            obj.H = zeros(obj.M, obj.N);
            
            for i_row = 1 : size(baseH, 1)
                for i_col = 1 : size(baseH, 2)
                    if baseH(i_row, i_col) ~= -1
                        obj.H( (i_row-1)*Z + 1 : i_row * Z, (i_col-1)*Z + 1 : i_col*Z) = circ_mat_array{baseH(i_row, i_col) + 1};
                    end
                    
                end
            end   

end

