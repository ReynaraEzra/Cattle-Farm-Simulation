clc;
clear all;
Day=0;
CattleProb=0.02; %Probabilitas Kemunculan Sapi
InfProb=0.125; %Probabilitas Sapi Tertular Infeksi
IsolProb=0; %Probabilitas Sapi Terinfeksi Diisolasi
InitInf=50; %Banyak Sapi Terinfeksi Diawal
InfPeriod=40; %Lama Sapi Terinfeksi Sembuh

map=[gray(8);1 0 0;0 1 0;0 0 1;0 1 1;1 0.5 0];
colormap(map);
%Akan Membuat Lahan Kosong
M=ones(126,103);
for i=1:9
    for j=1:103
        M(i,j)=5;
    end
end
M(10,:)=8;
for i=11:105
      M(i,18)=8;
      M(i,35)=8;
      M(i,52)=8;
      M(i,69)=8;
      M(i,86)=8;
end
M(106,1:53)=6;
M(106,54:103)=7;
M(107,1:103)=8;
M(107,53)=6;
M(107,54)=7;
M(108:126,1:54)=5;
M(108:126,53:54)=3;
M(108:126,55:77)=4;
M(108:126,78:79)=2;
M(108:126,80:103)=8;
M(1,:)=8;M(126,:)=8;
M(:,1)=8;M(:,103)=8;

%Farm Adalah Kondisi Kandang Dengan Sapinya
Farm = M; 
Sum = 0; %Jumlah Sapi 
Coordinate = zeros(1,2);
Weight = zeros(1,2);
for i = 11:105
    for j = 1:103
        if M(i,j) == 1;
            p = rand;
            if p < CattleProb
                Farm(i,j) = 11;
                Sum = Sum+1;
                Coordinate(Sum,1) = i;
                Coordinate(Sum,2) = j;
                Weight(Sum) = 40*rand+60;
            end
        end
    end
end
for i = 1:InitInf
    a = randi(Sum);
    Farm(Coordinate(a,1),Coordinate(a,2)) = 9;
    SickPeriod(i) = 0;
    InfCattle(i,1) = Coordinate(a,1);
    InfCattle(i,2) = Coordinate(a,2);
   end

image(Farm)
axis off
axis square

Isolated = 0; %Banyak Sapi Yang Diisolasi
Recovered = 0; %Banyak Sapi Yang Sudah Sembuh
Slaughtered = 0; %Banyak Sapi Yang Sudah Dipotong
NumSuscept = Sum - InitInf; %Banyak Sapi Yang Belum Terinfeksi
NumInf = InitInf;
Time1InSale = zeros(Sum,1); %Waktu Di SaleBarn Sebelum Memasuki Stocker
Time2InSale = zeros(Sum,1); %Waktu Di SaleBarn Sebelum Memasuki Feedlot
i = 1;
%while  Slaughtered ~= Sum %Looping Berjalan Ketika Banyak Sapi Terjagal Tidak Sama Dengan Banyak Sapi Total
F = getframe;
[im,map] = rgb2ind(F.cdata,256,'noidither');
im(1,1,1,2250) = 0;
for i =1:2250
    for x = 1:Sum
        South = [Coordinate(x,1)+1 Coordinate(x,2)]; %Cek Koordinat Arah Selatan
        North = [Coordinate(x,1)-1 Coordinate(x,2)]; %Cek Koordinat Arah Utara
        East = [Coordinate(x,1) Coordinate(x,2)+1]; %Cek Koordinat Arah Timur
        West = [Coordinate(x,1) Coordinate(x,2)-1]; %Cek Koordinat Arah Barat
        if Weight(x) < 600    
            Neighbour = [South; North; East; West]; %Pergerakan Random, Mengecek 4 Tetangga
            Neigh_Status = [Farm(South(1,1),South(1,2)); Farm(North(1,1),South(1,2)); Farm(East(1,1),East(1,2)); Farm(West(1,1),West(1,2))];
            Available_Neigh = find(Neigh_Status~=8 & Neigh_Status~=9 & Neigh_Status~=10 & Neigh_Status~=11 & Neigh_Status==M(Coordinate(x,1),Coordinate(x,2)));
            if Farm(Coordinate(x,1),Coordinate(x,2))~=12 && size(Available_Neigh,1) ~= 0 
                b = randi(size(Available_Neigh,1));
                Farm(Neighbour(Available_Neigh(b),1),Neighbour(Available_Neigh(b),2))=Farm(Coordinate(x,1),Coordinate(x,2));
                Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                Coordinate(x,1) = Neighbour(Available_Neigh(b),1);
                Coordinate(x,2) = Neighbour(Available_Neigh(b),2);
            end
            Weight(x) = Weight(x)+0.25*rand+0.5; %Menambah Berat Antara 0.5 sampai 0.75
        else if Weight(x) < 900
            Neighbour = [East; West];
            Neigh_Status = [Farm(East(1,1),East(1,2)); Farm(West(1,1),West(1,2))];
            Available_Neigh = find(Neigh_Status==1);
            if M(Coordinate(x,1),Coordinate(x,2))==1
                if Farm(South(1,1),South(1,2))==1 || Farm(South(1,1),South(1,2))==6 || Farm(South(1,1),South(1,2))==7
                    if Farm(South(1,1),South(1,2))~=8 && Farm(South(1,1),South(1,2))~=9 && Farm(South(1,1),South(1,2))~=10 && Farm(South(1,1),South(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                        Farm(South(1,1),South(1,2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                        Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                        Coordinate(x,1) = Coordinate(x,1)+1;
                    end
                else if size(Available_Neigh,1) ~= 0
                        c = randi(size(Available_Neigh,1));
                        Farm(Neighbour(Available_Neigh(c),1),Neighbour(Available_Neigh(c),2))=Farm(Coordinate(x,1),Coordinate(x,2));
                        Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                        Coordinate(x,1) = Neighbour(Available_Neigh(c),1);
                        Coordinate(x,2) = Neighbour(Available_Neigh(c),2);
                    end
                end
            else if M(Coordinate(x,1),Coordinate(x,2))==7
                    if Farm(South(1,1),South(1,2))==7 || Farm(South(1,1),South(1,2))==3
                        if Farm(South(1,1),South(1,2))~=8 && Farm(South(1,1),South(1,2))~=9 && Farm(South(1,1),South(1,2))~=10 && Farm(South(1,1),South(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                            Farm(South(1,1),South(1,2))=Farm(Coordinate(x,1),Coordinate(x,2));
                            Farm(Coordinate(x,1),Coordinate(x,2))=M(Coordinate(x,1),Coordinate(x,2));
                            Coordinate(x,1) = Coordinate(x,1)+1;
                        end
                        if M(Coordinate(x,1),Coordinate(x,2))==3                
                            Time1InSale(x) = randi(5); %Random Integer Antara 1 dan 5 dalam 1 hari (iterasi Program Setiap 0.25 Hari)
                        end
                    else if Farm(West(1,1),West(1,2))==7
                            if Farm(West(1,1),West(1,2))~=8 && Farm(West(1,1),West(1,2))~=9 && Farm(West(1,1),West(1,2))~=10 && Farm(West(1,1),West(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                                Farm(West(1,1),West(1,2))=Farm(Coordinate(x,1),Coordinate(x,2));
                                Farm(Coordinate(x,1),Coordinate(x,2))=M(Coordinate(x,1),Coordinate(x,2));
                                Coordinate(x,2) = Coordinate(x,2)-1;
                            end
                        end
                    end
                else if M(Coordinate(x,1),Coordinate(x,2))==6
                        if Farm(South(1,1),South(1,2))==6
                            if Farm(South(1,1),South(1,2))~=8 && Farm(South(1,1),South(1,2))~=9 && Farm(South(1,1),South(1,2))~=10 && Farm(South(1,1),South(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                                Farm(South(1,1),South(1,2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                                Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                                Coordinate(x,1) = Coordinate(x,1)+1;
                            end
                        else if Farm(East(1,1),East(1,2))==6 || Farm(East(1,1),East(1,2))==7
                                if Farm(East(1,1),East(1,2))~=8 && Farm(East(1,1),East(1,2))~=9 && Farm(East(1,1),East(1,2))~=10 && Farm(East(1,1),East(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                                    Farm(East(1,1),East(1,2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                                    Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                                    Coordinate(x,2) = Coordinate(x,2)+1;
                                end
                            end
                        end
                    else if M(Coordinate(x,1),Coordinate(x,2))==3               
                            if (Farm(West(1,1),West(1,2))==3 || Farm(West(1,1),West(1,2))==5) && Time1InSale(x)>8 
                                if Farm(West(1,1),West(1,2))~=8 && Farm(West(1,1),West(1,2))~=9 && Farm(West(1,1),West(1,2))~=10 && Farm(West(1,1),West(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                                    Farm(West(1,1),West(1,2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                                    Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                                    Coordinate(x,2) = Coordinate(x,2)-1;
                                end
                            else if Farm(South(1,1),South(1,2))==3
                                   if Farm(South(1,1),South(1,2))~=8 && Farm(South(1,1),South(1,2))~=9 && Farm(South(1,1),South(1,2))~=10 && Farm(South(1,1),South(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                                       Farm(South(1,1),South(1,2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                                       Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                                       Coordinate(x,1) = Coordinate(x,1)+1;
                                   end
                                    Time1InSale(x) = Time1InSale(x)+1;
                                end
                            end                     
                        else if Weight(x)<900 && M(Coordinate(x,1),Coordinate(x,2))==5
                                Neighbour = [South; North; East; West];
                                Neigh_Status = [Farm(South(1,1),South(1,2)); Farm(North(1,1),North(1,2)); Farm(East(1,1),East(1,2)); Farm(West(1,1),West(1,2))];
                                Available_Neigh = find(Neigh_Status~=8 & Neigh_Status~=9 & Neigh_Status~=10 & Neigh_Status~=11 & Neigh_Status==M(Coordinate(x,1),Coordinate(x,2)));
                                if Farm(Coordinate(x,1),Coordinate(x,2))~=12 && size(Available_Neigh,1) ~= 0  
                                    d = randi(size(Available_Neigh,1));
                                    Farm(Neighbour(Available_Neigh(d),1),Neighbour(Available_Neigh(d),2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                                    Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                                    Coordinate(x,1) = Neighbour(Available_Neigh(d),1);
                                    Coordinate(x,2) = Neighbour(Available_Neigh(d),2);
                                end
                                Weight(x) = Weight(x)+0.2*rand+0.4; %Menambah Berat Antara 0.4 Sampai 0.6
                            end
                        end
                    end
                end
            end
            else if Weight(x) < 1300
                    Neighbour = [East; West];
                    Neigh_Status = [Farm(East(1,1),East(1,2)); Farm(West(1,1),West(1,2))];
                    Available_Neigh = find(Neigh_Status==5);
                    if M(Coordinate(x,1),Coordinate(x,2))==5
                        if Farm(East(1,1),East(1,2))~=8 && Farm(East(1,1),East(1,2))~=9 && Farm(East(1,1),East(1,2))~=10 && Farm(East(1,1),East(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                            Farm(East(1,1),East(1,2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                            Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                            Coordinate(x,2) = Coordinate(x,2)+1;
                        end
                        if M(Coordinate(x,1),Coordinate(x,2))==3
                            Time2InSale(x) = randi(5);
                        end
                    else if M(Coordinate(x,1),Coordinate(x,2))==3
                            if Time2InSale(x) > 8
                                if Farm(East(1,1),East(1,2))~=8 && Farm(East(1,1),East(1,2))~=9 && Farm(East(1,1),East(1,2))~=10 && Farm(East(1,1),East(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                                   Farm(East(1,1),East(1,2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                                   Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                                   Coordinate(x,2) = Coordinate(x,2)+1;
                                end
                            else
                                Time2InSale(x) = Time2InSale(x) + 1;
                            end
                        else if M(Coordinate(x,1),Coordinate(x,2))==4
                              Neighbour = [South; North; East];
                              Neigh_Status = [Farm(South(1,1),South(1,2)); Farm(North(1,1),North(1,2)); Farm(East(1,1),East(1,2))];
                              Available_Neigh = find(Neigh_Status~=8 & Neigh_Status~=9 & Neigh_Status~=10 & Neigh_Status~=11 & Neigh_Status==M(Coordinate(x,1),Coordinate(x,2)));
                              if size(Available_Neigh,1) ~= 0 && Farm(Coordinate(x,1),Coordinate(x,2))~=12
                                  e = randi(size(Available_Neigh,1));
                                  Farm(Neighbour(Available_Neigh(e),1),Neighbour(Available_Neigh(e),2))=Farm(Coordinate(x,1),Coordinate(x,2));
                                  Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                                  Coordinate(x,1) = Neighbour(Available_Neigh(e),1);
                                  Coordinate(x,2) = Neighbour(Available_Neigh(e),2);
                              end
                                Weight(x) = Weight(x)+0.5*rand+0.5; %Menambah Berat Antara 0.5 Sampai 1
                            end
                        end
                    end           
                else
                    if M(Coordinate(x,1),Coordinate(x,2))==4
                        if Farm(East(1,1),East(1,2))~=8 && Farm(East(1,1),East(1,2))~=9 && Farm(East(1,1),East(1,2))~=10 && Farm(East(1,1),East(1,2))~=11 && Farm(Coordinate(x,1),Coordinate(x,2))~=12 && Farm(Coordinate(x,1),Coordinate(x,2))~=9
                            Farm(East(1,1),East(1,2)) = Farm(Coordinate(x,1),Coordinate(x,2));
                            Farm(Coordinate(x,1),Coordinate(x,2)) = M(Coordinate(x,1),Coordinate(x,2));
                            Coordinate(x,2) = Coordinate(x,2)+1;
                        end
                        if M(Coordinate(x,1),Coordinate(x,2))==2
                            Farm(Coordinate(x,1),Coordinate(x,2))=13;
                            Slaughtered = Slaughtered+1; %Banyaknya Sapi Yang Sudah Dijagal
                        end
                    end
                end
            end
        end
    end
    
    colormap(map);
    n = size(Coordinate,1);
    k = 0;
    l = size(InfCattle,1);
    for j=1:n;
        s = size(InfCattle,1);
        if Farm(Coordinate(j,1),Coordinate(j,2))==9 || Farm(Coordinate(j,1),Coordinate(j,2))==10 || Farm(Coordinate(j,1),Coordinate(j,2))==12
            k = k+1;
            InfCattle(k,1) = Coordinate(j,1);
            InfCattle(k,2) = Coordinate(j,2);
            if Farm(Coordinate(j,1),Coordinate(j,2))==9 || Farm(Coordinate(j,1),Coordinate(j,2))==12
                if SickPeriod(k) > InfPeriod
                    Farm(Coordinate(j,1),Coordinate(j,2))=10;
                    NumInf = NumInf-1; %Banyak Sapi Terinfeksi
                    Recovered=Recovered+1; %Banyak Sapi Sembuh
                else
                    SickPeriod(k) = SickPeriod(k)+0.25;              
                    if Farm(Coordinate(j,1),Coordinate(j,2))==9
                        f = rand;
                        if f < IsolProb
                            Farm(Coordinate(j,1),Coordinate(j,2))=12;
                            Isolated = Isolated+1; %Banyak Sapi Terisolasi
                        end
                    end
                end
            end
        else
            if Farm(Coordinate(j,1)+1,Coordinate(j,2))==9 || Farm(Coordinate(j,1)-1,Coordinate(j,2))==9 || Farm(Coordinate(j,1),Coordinate(j,2)+1)==9 || Farm(Coordinate(j,1),Coordinate(j,2)-1)==9
                h = rand;
                if h < InfProb
                    Farm(Coordinate(j,1),Coordinate(j,2))=9;
                    NumSuscept = NumSuscept-1;
                    NumInf = NumInf+1;
                    InfCattle(l+1,1) = Coordinate(j,1);
                    InfCattle(l+1,2) = Coordinate(j,2);
                    SickPeriod(l+1) = 0;
                end
            end
        end
    end
    image(Farm)
    str='Hari ke-';
    num=floor(Day)+1;
    title([str num2str(num)]);
    axis off
    axis square
    F = getframe;
    im(:,:,1,i) = rgb2ind(F.cdata,map,'noidither');
    Day = Day+0.25;
end
imwrite(im,map,'Cattle Farm.gif','Delay Time',0,'LoopCount',inf)
writeAnimation('wheel.gif')