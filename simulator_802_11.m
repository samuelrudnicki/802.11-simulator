%INF01005 - Comunica��o de Dados
%Trabalho Final

%Grupo 5
%ALBERTO PENA NETO
%ENRICO FERRARI OSSANAI
%SAMUEL RUDNICKI	

%MODULACAO
%BPSK, 64-QAM

%CODIGO DE CANAL
%LDPC n = 1296, R = {1/2, 5/6}

clear all;
close all;

frame_size=1500*8; %quantidades de bits por frame
num_frames=27; %numero de frames simulados
num_b = num_frames*frame_size; %numero de bits simulados

n_it_max=10; %numero maximo de iteracoes para approx ldcp
Eb_N0_dB = -5:0.5:10; %faixa de Eb/N0 a ser simulada (em dB)

%Es_N0
Es_N0_dB_64QAM_1_2=Eb_N0_dB + 10*log10(6*(1/2));
Es_N0_dB_64QAM_5_6=Eb_N0_dB + 10*log10(6*(5/6));
Es_N0_dB_BPSK_1_2=Eb_N0_dB + 10*log10(1/2);
Es_N0_dB_BPSK_5_6=Eb_N0_dB + 10*log10(5/6);

%pre-alocacao de vetores BER
ber_64QAM_1_2 = zeros(size(Eb_N0_dB));% conta erros e calcula o BER
ber_64QAM_5_6 = zeros(size(Eb_N0_dB));
ber_BPSK_1_2 = zeros(size(Eb_N0_dB));
ber_BPSK_5_6 = zeros(size(Eb_N0_dB));
%pre-alocacao de vetores FER
fer_64QAM_1_2 = zeros(size(Eb_N0_dB));% conta erros e calcula o FER
fer_64QAM_5_6 = zeros(size(Eb_N0_dB));
fer_BPSK_1_2 = zeros(size(Eb_N0_dB));
fer_BPSK_5_6 = zeros(size(Eb_N0_dB));


%FONTE DE INFORMACAO
bits=randi([0 1],num_b,1);

%CODIFICACAO
%LDPC
N=1296;
R1 = '1/2';
R2 = '5/6';

length_1_2=N*1/2;
length_5_6=N*5/6;

%gerando matrizes esparsas
H_sparse_1_2= generate_sparse_matrix(R1);
H_sparse_5_6= generate_sparse_matrix(R2);

%gerando objetos LDPC encoder
LDPC_encoder_1_2 = comm.LDPCEncoder(H_sparse_1_2);
LDPC_encoder_5_6 = comm.LDPCEncoder(H_sparse_5_6);

%gerando objetos LDPC decoder
LDPC_decoder_1_2 = comm.LDPCDecoder(H_sparse_1_2, 'IterationTerminationCondition', 'Parity check satisfied', 'MaximumIterationCount', n_it_max,'NumIterationsOutputPort', true);
LDPC_decoder_5_6 = comm.LDPCDecoder(H_sparse_5_6, 'IterationTerminationCondition', 'Parity check satisfied', 'MaximumIterationCount', n_it_max,'NumIterationsOutputPort', true);

%ajustando formato de bits de entrada
info_bits_1_2=vec2mat(bits,length_1_2);
info_bits_5_6=vec2mat(bits,length_5_6);

bits_LDPC_encoded_1_2 = [ ];
bits_LDPC_encoded_5_6 = [ ];

%codificando todos os valores da entrada para LDPC
for ii=1:size(info_bits_1_2,1)
bits_LDPC_encoded_1_2_n= step(LDPC_encoder_1_2, info_bits_1_2(ii,:)');
bits_LDPC_encoded_1_2=cat(1,bits_LDPC_encoded_1_2,bits_LDPC_encoded_1_2_n);
end

for ii=1:size(info_bits_5_6,1)
bits_LDPC_encoded_5_6_n= step(LDPC_encoder_5_6, info_bits_5_6(ii,:)');
bits_LDPC_encoded_5_6=cat(1,bits_LDPC_encoded_5_6,bits_LDPC_encoded_5_6_n);
end

%
%MODULACAO
%
%BPSK
BPSK_modulator = comm.BPSKModulator;
BPSK_demodulator = comm.BPSKDemodulator('DecisionMethod','Approximate log-likelihood ratio');

codBPSK_LDPC_1_2 = step(BPSK_modulator,bits_LDPC_encoded_1_2);
codBPSK_LDPC_5_6 = step(BPSK_modulator,bits_LDPC_encoded_5_6);

%64-QAM
M=64;
n=log2(M);

QAM64_modulator=comm.RectangularQAMModulator('ModulationOrder',64,'BitInput',true);
QAM64_demodulator=comm.RectangularQAMDemodulator('ModulationOrder',64,'DecisionMethod','Approximate log-likelihood ratio','BitOutput',true);

cod64QAM_LDPC_1_2 = step(QAM64_modulator,bits_LDPC_encoded_1_2);
cod64QAM_LDPC_5_6=step(QAM64_modulator,bits_LDPC_encoded_5_6);

for i = 1:length(Eb_N0_dB)
    
    %adicao de ruidos
    c_BPSK_1_2 = awgn(codBPSK_LDPC_1_2,Es_N0_dB_BPSK_1_2(i),'measured');
    c_BPSK_5_6 = awgn(codBPSK_LDPC_5_6,Es_N0_dB_BPSK_5_6(i),'measured');
    c_64QAM_1_2 = awgn(cod64QAM_LDPC_1_2,Es_N0_dB_64QAM_1_2(i),'measured');
    c_64QAM_5_6 = awgn(cod64QAM_LDPC_5_6,Es_N0_dB_64QAM_5_6(i),'measured');
    
    %recuperando informa��o p�s canal
    %filtrando ruidos e demodulando
    
    r_BPSK_1_2=step(BPSK_demodulator,c_BPSK_1_2);
    r_BPSK_5_6=step(BPSK_demodulator,c_BPSK_5_6);
    
    r_64QAM_1_2 = step(QAM64_demodulator,c_64QAM_1_2);
    r_64QAM_5_6 = step(QAM64_demodulator,c_64QAM_5_6);
 
   
    %decodificando
    %ajustando formato dos bits
    r_BPSK_1_2=vec2mat(r_BPSK_1_2,N);
    r_BPSK_5_6=vec2mat(r_BPSK_5_6,N);
    r_64QAM_1_2=vec2mat(r_64QAM_1_2,N);
    r_64QAM_5_6=vec2mat(r_64QAM_5_6,N);
    
    decoded_bits_64QAM_1_2 = [ ];
    decoded_bits_64QAM_5_6 = [ ];
    decoded_bits_BPSK_1_2 = [ ];
    decoded_bits_BPSK_5_6 = [ ];
    
    
    %decodificando todos os valores com LDPC
    for ii=1:size(r_64QAM_1_2,1)
        decoded_bits_64QAM_1_2_n = step(LDPC_decoder_1_2, r_64QAM_1_2(ii,:)');
        decoded_bits_64QAM_1_2=cat(1,decoded_bits_64QAM_1_2,decoded_bits_64QAM_1_2_n);
               
        decoded_bits_BPSK_1_2_n = step(LDPC_decoder_1_2, r_BPSK_1_2(ii,:)');
        decoded_bits_BPSK_1_2=cat(1,decoded_bits_BPSK_1_2,decoded_bits_BPSK_1_2_n);
    end
    for ii=1:size(r_64QAM_5_6,1)
        decoded_bits_64QAM_5_6_n = step(LDPC_decoder_5_6, r_64QAM_5_6(ii,:)');
        decoded_bits_64QAM_5_6=cat(1,decoded_bits_64QAM_5_6,decoded_bits_64QAM_5_6_n);
        
        decoded_bits_BPSK_5_6_n= step(LDPC_decoder_5_6, r_BPSK_5_6(ii,:)');
        decoded_bits_BPSK_5_6=cat(1,decoded_bits_BPSK_5_6,decoded_bits_BPSK_5_6_n);
    end

    %calculando BER para o Eb/N0 atual
    ber_64QAM_1_2(i) = sum(bits ~= decoded_bits_64QAM_1_2) / num_b;
    ber_64QAM_5_6(i) = sum(bits ~= decoded_bits_64QAM_5_6) / num_b;
    ber_BPSK_1_2(i) = sum(bits ~= decoded_bits_BPSK_1_2) / num_b;
    ber_BPSK_5_6(i) = sum(bits ~= decoded_bits_BPSK_5_6) / num_b;
    %calculando FER para o Eb/N0 atual
    fer_64QAM_1_2(i) = sum(bits ~= decoded_bits_64QAM_1_2) /num_frames;
    fer_64QAM_5_6(i) = sum(bits ~= decoded_bits_64QAM_5_6) /num_frames;
    fer_BPSK_1_2(i) = sum(bits ~= decoded_bits_BPSK_1_2) / num_frames;
    fer_BPSK_5_6(i) = sum(bits ~= decoded_bits_BPSK_5_6) / num_frames;
end

semilogy(Eb_N0_dB, ber_64QAM_1_2,'-*', Eb_N0_dB, ber_64QAM_5_6,'-o', Eb_N0_dB, ber_BPSK_1_2,'-+', Eb_N0_dB, ber_BPSK_5_6,'-x', 'LineWidth', 2);
grid on;
title('BER - BPSK e 64QAM');
legend('64-QAM, R=1/2', '64-QAM, R=5/6', 'BPSK, R=1/2', 'BPSK, R=5/6');
ylabel('BER');
xlabel('Eb/N0 (dB)');   
            
figure;
semilogy(Eb_N0_dB, fer_64QAM_1_2,'-*', Eb_N0_dB, fer_64QAM_5_6,'-o', Eb_N0_dB, fer_BPSK_1_2,'-+', Eb_N0_dB, fer_BPSK_5_6,'-x', 'LineWidth', 2);
grid on;
title('FER - BPSK e 64QAM');
legend('64-QAM, R=1/2', '64-QAM, R=5/6', 'BPSK, R=1/2', 'BPSK, R=5/6');
ylabel('FER');
xlabel('Eb/N0 (dB)');   
