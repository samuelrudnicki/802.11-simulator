%INF01005 - Comunicação de Dados
%Trabalho Final

%Grupo 5
%ALBERTO PENA NETO
%ENRICO FERRARI OSSANAI
%SAMUEL RUDNICKI	

%MODULACAO
%BPSK, 64-QAM

%CODIGO DE CANAL
%LDPC n = 1296, R = {1/2, 5/6}

%Gera uma matrix H esparça com base nos protótipos disponibilizados
%Essa matriz é gerada para possibilitar o uso de 
%comm.LDPCEncoder e comm.LDPCDecoder
function H_sparse = generate_sparse_matrix(rate)

 switch rate
     case '1/2'
        H_prototype =[40 -1 -1 -1 22 -1 49 23 43 -1 -1 -1 1 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1;
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
     case '5/6'
        H_prototype = [48 29 37 52 2 16 6 14 53 31 34 5 18 42 53 31 45 -1 46 52 1 0 -1 -1;
                17 4 30 7 43 11 24 6 14 21 6 39 17 40 47 7 15 41 19 -1 -1 0 0 -1;
                7 2 51 31 46 23 16 11 53 40 10 7 46 53 33 35 -1 25 35 38 0 -1 0 0;
                19 48 41 1 10 7 36 47 5 29 52 52 31 10 26 6 3 2 -1 51 1 -1 -1 0 ];
     otherwise
         error('Error: rate not supported'); 
 end
   
 [num_row, num_col] = size(H_prototype);
 size_subm = 54; %tamanho da submatriz - padrao para n=1268
 
 for i_row = 1 : num_row
    for i_col = 1 : num_col
        if H_prototype(i_row,i_col) == -1
            H_sparse(1+(i_row-1)*size_subm : i_row*size_subm, 1+(i_col-1)*size_subm : i_col*size_subm)= sparse(zeros(size_subm, size_subm));
        else
            H_sparse(1+(i_row-1)*size_subm : i_row*size_subm, 1+(i_col-1)*size_subm : i_col*size_subm)= sparse(circshift(eye(size_subm), -H_prototype(i_row,i_col)));
        end
    end
 end 
end

