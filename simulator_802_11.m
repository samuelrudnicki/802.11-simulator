%% 802.11 simulator
 %Simulation of IEEE 802.11
 %   
 %Simulates and compares the performance of different modulations and channel codings of IEEE 802.11. Compared in terms of bit error rate (BER) and frame error rate (FER), considering frames of 1500 bytes.
 %
 %Modulations:  BPSK, 64-QAM
 %
 %Channel codings: LDPC n = 1296, R = {1/2, 5/6}
%%

clear all;
close all;

num_b = 1080*648; %quantidade de bits simulados

Eb = 1; %energia por símbolo é constante (1^2 = (-1)^2 = 1), 1 bit por símbolo (caso geral: energia média por símbolo / bits por símbolo)
Eb_N0_dB = 2:1:12; %faixa de Eb/N0 a ser simulada (em dB)
Eb_N0_lin = Eb .^ (Eb_N0_dB/10); %Eb/N0 linearizado
NP = Eb ./ (Eb_N0_lin); %potência do ruído
NA = sqrt(NP); %amplitude é a raiz quadrada da potência

ber = zeros(size(Eb_N0_lin)); %pre-allocates BER vector

%FONTE DE INFORMACAO
bits=randi([0 1],1,num_b);

%CODIFICACAO
%LDPC

N= 1296;
R1 = 1/2;
R2 = 5/6;

ldpc_code_1_2 = LDPCCode(0, 0);
ldpc_code_5_6 = LDPCCode(0, 0);
ldpc_code_1_2.load_wifi_ldpc(N, R1);
ldpc_code_5_6.load_wifi_ldpc(N, R2);

length_1_2=ldpc_code_1_2.K;
length_5_6=ldpc_code_5_6.K;

info_bits_1_2=vec2mat(bits,length_1_2);
info_bits_5_6=vec2mat(bits,length_5_6);

coded_bits_1_2={};
coded_bits_5_6={};

for ii=1:size(info_bits_1_2,1)
    coded_bits_1_2 = [coded_bits_1_2,ldpc_code_1_2.encode_bits(info_bits_1_2(ii,:))'];
end

for ii=1:size(info_bits_5_6,1)
    coded_bits_5_6 = [coded_bits_5_6,ldpc_code_5_6.encode_bits(info_bits_5_6(ii,:))'];
end

coded_bits_1_2 = horzcat(coded_bits_1_2{:});
coded_bits_5_6 = horzcat(coded_bits_5_6{:});
%MODULACAO
%BPSK
codBPSK_LDPC_1_2 = coded_bits_1_2;
codBPSK_LDPC_1_2(codBPSK_LDPC_1_2==0)=complex(-1, 0);

codBPSK_LDPC_5_6 = coded_bits_5_6;
codBPSK_LDPC_5_6(codBPSK_LDPC_5_6==1)=complex(1, 0);

%64-QAM
M=64;
n=log2(M); %
cod64QAM_LDPC_1_2=reshape(coded_bits_1_2,n,[]);
cod64QAM_LDPC_1_2=bi2de(cod64QAM_LDPC_1_2','left-msb');
cod64QAM_LDPC_1_2=cod64QAM_LDPC_1_2';
cod64QAM_LDPC_1_2=qammod(cod64QAM_LDPC_1_2,M);

cod64QAM_LDPC_5_6=reshape(coded_bits_5_6,n,[]);
cod64QAM_LDPC_5_6=bi2de(cod64QAM_LDPC_5_6','left-msb');
cod64QAM_LDPC_5_6=cod64QAM_LDPC_5_6';
cod64QAM_LDPC_5_6=qammod(cod64QAM_LDPC_5_6,M);

for i = 1:length(Eb_N0_lin)
    
    % geração de ruídos
    n_BPSK_1_2 = NA(i)*complex(randn(1, length(codBPSK_LDPC_1_2)), randn(1, length(codBPSK_LDPC_1_2)))*sqrt(0.5); %vetor de ruído com desvio padrão igual à amplitude do ruído        n = NA(i)*complex(randn(1, length(encData)), randn(1, length(encData)))*sqrt(0.5); %vetor de ruído com desvio padrão igual à amplitude do ruído
    n_BPSK_5_6 = NA(i)*complex(randn(1, length(codBPSK_LDPC_5_6)), randn(1, length(codBPSK_LDPC_5_6)))*sqrt(0.5); %vetor de ruído com desvio padrão igual à amplitude do ruído
    n_64QAM_1_2 = NA(i)*complex(randn(1, length(cod64QAM_LDPC_1_2)), randn(1, length(cod64QAM_LDPC_1_2)))*sqrt(0.5); %vetor de ruído com desvio padrão igual à amplitude do ruído
    n_64QAM_5_6 = NA(i)*complex(randn(1, length(cod64QAM_LDPC_5_6)), randn(1, length(cod64QAM_LDPC_5_6)))*sqrt(0.5); %vetor de ruído com desvio padrão igual à amplitude do ruído
    
    % canal AWNG
    r_BPSK_1_2 = codBPSK_LDPC_1_2 + n_BPSK_1_2; 
    r_BPSK_5_6 = codBPSK_LDPC_5_6 + n_BPSK_5_6;
    r_64QAM_1_2 = cod64QAM_LDPC_1_2 + n_64QAM_1_2;
    r_64QAM_5_6 = cod64QAM_LDPC_5_6 + n_64QAM_5_6;
    
    %recuperando informação pós canal
    %filtrando ruidos e demodulando
    r_BPSK_1_2(real(r_BPSK_1_2)>=0)=1;
    r_BPSK_1_2(real(r_BPSK_1_2)<0)=0;
    
    r_BPSK_5_6(real(r_BPSK_5_6)>=0)=1;
    r_BPSK_5_6(real(r_BPSK_5_6)<0)=0;
    
    r_64QAM_1_2 = qamdemod(r_64QAM_1_2,M);
    r_64QAM_1_2 = de2bi(r_64QAM_1_2,n,'left-msb');
    r_64QAM_1_2 = r_64QAM_1_2';
    r_64QAM_1_2 = r_64QAM_1_2(:)';
    
    r_64QAM_5_6 = qamdemod(r_64QAM_5_6,M);
    r_64QAM_5_6 = de2bi(r_64QAM_5_6,n,'left-msb');
    r_64QAM_5_6 = r_64QAM_5_6';
    r_64QAM_5_6 = r_64QAM_5_6(:)';
   
    %decodificando
    max_decode_iterations = 50;
    
    decoded_BPSK_1_2=vec2mat(r_BPSK_1_2,N);
    decoded_BPSK_5_6=vec2mat(r_BPSK_5_6,N);
    decoded_64QAM_1_2=vec2mat(r_64QAM_1_2,N);
    decoded_64QAM_5_6=vec2mat(r_64QAM_5_6,N);

    decoded_bits_BPSK_1_2={};
    decoded_bits_BPSK_5_6={};
    decoded_bits_64QAM_1_2={};
    decoded_bits_64QAM_5_6={};

for ii=1:size(decoded_BPSK_1_2,1)
    decoded_bits_BPSK_1_2 = [decoded_bits_BPSK_1_2,ldpc_code_1_2.decode_llr(decoded_BPSK_1_2(ii,:),max_decode_iterations,1)'];
    decoded_bits_BPSK_1_2(end-length_5_6:end)=[];
    
    decoded_bits_64QAM_1_2 = [decoded_bits_64QAM_1_2,ldpc_code_1_2.decode_llr(decoded_64QAM_1_2(ii,:),max_decode_iterations,1)'];
    decoded_bits_64QAM_1_2(end-length_5_6:end)=[];
end

for ii=1:size(decoded_BPSK_5_6,1)
    decoded_bits_BPSK_5_6 = [decoded_bits_BPSK_5_6,ldpc_code_5_6.decode_llr(decoded_BPSK_5_6(ii,:),max_decode_iterations,1)'];
    decoded_bits_BPSK_5_6(end-length_5_6:end)=[];
    
    decoded_bits_64QAM_5_6 = [decoded_bits_64QAM_5_6,ldpc_code_5_6.decode_llr(decoded_64QAM_5_6(ii,:),max_decode_iterations,1)'];
    decoded_bits_64QAM_5_6(end-length_5_6:end)=[];
end

    
decoded_bits_BPSK_1_2 = horzcat(decoded_bits_BPSK_1_2{:});
decoded_bits_64QAM_1_2 = horzcat(decoded_bits_64QAM_1_2{:});

decoded_bits_BPSK_5_6 = horzcat(decoded_bits_BPSK_5_6{:});
decoded_bits_64QAM_5_6 = horzcat(decoded_bits_64QAM_5_6{:});
    
    ber(i) = sum(bits ~= demod) / num_b; % conta erros e calcula o BER
    ber
end

ber_theoretical = 0.5*erfc(sqrt(Eb_N0_lin)); %BER teórico

semilogy(Eb_N0_dB, ber, Eb_N0_dB, ber_theoretical, 'LineWidth', 2);
grid on;
title('Taxa de erros para BPSK');
legend('Medido', 'Teórico');
ylabel('BER');
xlabel('Eb/N0 (dB)');   