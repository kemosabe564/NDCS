%%%%%
%%% p1c
%%%%%
Nesterov=struct;

Nesterov.sub_aircraft_number=4;
Nesterov.lambda=zeros(4,nx);
Nesterov.history_lambda=Nesterov.lambda;
Nesterov.initial_update_step=0.0005;
Nesterov.update_step=Nesterov.initial_update_step;

Nesterov.centralized_result=cvx_optval;
Nesterov.error=1;
Nesterov.master_error=Nesterov.error;

i=0;

aircraft_1.sub_error=[];
aircraft_2.sub_error=[];
aircraft_3.sub_error=[];
aircraft_4.sub_error=[];

previous_temp_lambda=zeros(4,4);

while Nesterov.error>0.0001  

    aircraft_1_optimization
    aircraft_2_optimization
    aircraft_3_optimization
    aircraft_4_optimization

    temp_lambda=Nesterov.lambda;
    temp_lambda(1,:)=temp_lambda(1,:)+Nesterov.update_step*(aircraft_1.distributed_final_state-aircraft_2.distributed_final_state)';
    temp_lambda(2,:)=temp_lambda(2,:)+Nesterov.update_step*(aircraft_2.distributed_final_state-aircraft_3.distributed_final_state)';
    temp_lambda(3,:)=temp_lambda(3,:)+Nesterov.update_step*(aircraft_3.distributed_final_state-aircraft_4.distributed_final_state)';
    temp_lambda(4,:)=temp_lambda(4,:)+Nesterov.update_step*(aircraft_4.distributed_final_state-aircraft_1.distributed_final_state)';
    
    Nesterov.lambda=temp_lambda + (i+1)/(i+4)* (temp_lambda-previous_temp_lambda);

    Nesterov.history_lambda=[Nesterov.history_lambda;Nesterov.lambda];


    aircraft_1.decentralized_result=(aircraft_1.P *aircraft_1.u + aircraft_1.Q * x01)' * (aircraft_1.P *aircraft_1.u + aircraft_1.Q * x01)...,
                                + aircraft_1.u' * aircraft_1.u + x01'*x01;
    aircraft_1.error=abs(aircraft_1.decentralized_result-aircraft_1.centralized_result)/aircraft_1.centralized_result;
    aircraft_1.sub_error=[aircraft_1.sub_error,aircraft_1.error];

    aircraft_2.decentralized_result=(aircraft_2.P *aircraft_2.u + aircraft_2.Q * x02)' * (aircraft_2.P *aircraft_2.u + aircraft_2.Q * x02)...,
                                + aircraft_2.u' * aircraft_2.u + x02'*x02;
    aircraft_2.error=abs(aircraft_2.decentralized_result-aircraft_2.centralized_result)/aircraft_2.centralized_result;
    aircraft_2.sub_error=[aircraft_2.sub_error,aircraft_2.error];

    aircraft_3.decentralized_result=(aircraft_3.P*aircraft_3.u + aircraft_3.Q * x03)' * (aircraft_3.P *aircraft_3.u + aircraft_3.Q * x03)...,
                                + aircraft_3.u' * aircraft_3.u + x03'*x03;
    aircraft_3.error=abs(aircraft_3.decentralized_result-aircraft_3.centralized_result)/aircraft_3.centralized_result;
    aircraft_3.sub_error=[aircraft_3.sub_error,aircraft_3.error];

    aircraft_4.decentralized_result=(aircraft_4.P *aircraft_4.u + aircraft_4.Q * x04)' * (aircraft_4.P *aircraft_4.u + aircraft_4.Q * x04)...,
                                + aircraft_4.u' * aircraft_4.u + x04'*x04;
    aircraft_4.error=abs(aircraft_4.decentralized_result-aircraft_4.centralized_result)/aircraft_4.centralized_result;
    aircraft_4.sub_error=[aircraft_4.sub_error,aircraft_4.error];

    dual_part=Nesterov.lambda(1,:)*(aircraft_1.distributed_final_state-aircraft_2.distributed_final_state)...,
                + Nesterov.lambda(2,:)*(aircraft_2.distributed_final_state-aircraft_3.distributed_final_state)...,
                + Nesterov.lambda(3,:)*(aircraft_3.distributed_final_state-aircraft_4.distributed_final_state)...,
                + Nesterov.lambda(4,:)*(aircraft_4.distributed_final_state-aircraft_1.distributed_final_state);


    Nesterov.decentralized_result=aircraft_1.decentralized_result + aircraft_2.decentralized_result ...,
                                        + aircraft_3.decentralized_result + aircraft_4.decentralized_result;
                                        


    Nesterov.error=abs(Nesterov.decentralized_result-Nesterov.centralized_result)/Nesterov.centralized_result;
    Nesterov.error
    Nesterov.master_error=[Nesterov.master_error,Nesterov.error];

    i=i+1

    previous_temp_lambda=temp_lambda;


end

temp_state_1=aircraft_1.initial_state;
temp_state_2=aircraft_2.initial_state;
temp_state_3=aircraft_3.initial_state;
temp_state_4=aircraft_4.initial_state;

state_1=[x01];
state_2=[x02];
state_3=[x03];
state_4=[x04];

for i=1:1:Tfinal

    temp_state_1=aircraft_1.A*temp_state_1+aircraft_1.B*aircraft_1.u(2*i-1:2*i);    
    temp_state_2=aircraft_2.A*temp_state_2+aircraft_2.B*aircraft_2.u(2*i-1:2*i);
    temp_state_3=aircraft_3.A*temp_state_3+aircraft_3.B*aircraft_3.u(2*i-1:2*i);
    temp_state_4=aircraft_4.A*temp_state_4+aircraft_4.B*aircraft_4.u(2*i-1:2*i);
    state_1=[state_1,temp_state_1];
    state_2=[state_2,temp_state_2];
    state_3=[state_3,temp_state_3];    
    state_4=[state_4,temp_state_4];

end 

aircraft_1.distributed_states=state_1;
aircraft_2.distributed_states=state_2;
aircraft_3.distributed_states=state_3;
aircraft_4.distributed_states=state_4;

%%
figure('Name','master problem error evolution with Nestorev method')
semilogy(Nesterov.master_error(2:end));
title('master problem error evolution with Nestorev method', 'FontSize', 16)
xlabel('iterations', 'FontSize', 16)
ylabel('error', 'FontSize', 16)
grid on

figure('Name','error evolution of each aircraft with Nestorev method')

semilogy(aircraft_1.sub_error);
hold on
semilogy(aircraft_2.sub_error);
hold on
semilogy(aircraft_3.sub_error);
hold on
semilogy(aircraft_4.sub_error);
legend('aircraft 1','aircraft 2','aircraft 3','aircraft 4');
grid on

title('error evolution of each aircraft with Nestorev method', 'FontSize', 16)
xlabel('iterations', 'FontSize', 16)
ylabel('error', 'FontSize', 16)



figure('Name','Question 1 Part 3 Normal Nestorev aircrafts final state transitions')

subplot(2,2,1)
plot(T_span,aircraft_1.distributed_states');
title('aircraft 1 distributed states with Nestorev method')
xlabel('time/t')
ylabel('state value')
grid on

subplot(2,2,2)
plot(T_span,aircraft_2.distributed_states');
title('aircraft 2 distributed states with Nestorev method')
xlabel('time/t')
ylabel('state value')
grid on

subplot(2,2,3)
plot(T_span,aircraft_3.distributed_states');
title('aircraft 3 distributed states with Nestorev method')
xlabel('time/t')
ylabel('state value')
grid on

subplot(2,2,4)
plot(T_span,aircraft_4.distributed_states');
title('aircraft 4 distributed states with Nestorev method')
xlabel('time/t')
ylabel('state value')
grid on




% % Nesto Accelerated in Machine Learning
% 
% Nesterov.sub_aircraft_number=4;
% Nesterov.update_step=0.001;
% 
% Nesterov.centralized_result=cvx_optval;
% Nesterov.error=1;
% Nesterov.master_error=Nesterov.error;
% 
% Nesterov.update_weight_current=0.9;
% Nesterov.update_weight_future=1;
% 
% current_lambda_moment=zeros(4,4);
% future_lambda_moment=zeros(4,4);
% 
% Nesterov.lambda=ones(4,nx);
% future_lambda=Nesterov.lambda;
% Nesterov.history_lambda=Nesterov.lambda;
% 
% i=0
% 
% aircraft_1.sub_error=[];
% aircraft_2.sub_error=[];
% aircraft_3.sub_error=[];
% aircraft_4.sub_error=[];
% 
% while Nesterov.error>0.01
% 
%     aircraft_1_optimization
%     aircraft_2_optimization
%     aircraft_3_optimization
%     aircraft_4_optimization
% 
%     current_lambda_moment(1,:)=Nesterov.update_step*(aircraft_1.distributed_final_state-aircraft_2.distributed_final_state)';
%     current_lambda_moment(2,:)=Nesterov.update_step*(aircraft_2.distributed_final_state-aircraft_3.distributed_final_state)';
%     current_lambda_moment(3,:)=Nesterov.update_step*(aircraft_3.distributed_final_state-aircraft_4.distributed_final_state)';
%     current_lambda_moment(4,:)=Nesterov.update_step*(aircraft_4.distributed_final_state-aircraft_1.distributed_final_state)';
% 
%     future_lambda=Nesterov.lambda+current_lambda_moment;
% 
%     temp_lambda=Nesterov.lambda;
%     Nesterov.lambda=future_lambda;
% 
%     aircraft_1_optimization
%     aircraft_2_optimization
%     aircraft_3_optimization
%     aircraft_4_optimization
% 
%     future_lambda_moment(1,:)=Nesterov.update_step*(aircraft_1.distributed_final_state-aircraft_2.distributed_final_state)';
%     future_lambda_moment(2,:)=Nesterov.update_step*(aircraft_2.distributed_final_state-aircraft_3.distributed_final_state)';
%     future_lambda_moment(3,:)=Nesterov.update_step*(aircraft_3.distributed_final_state-aircraft_4.distributed_final_state)';
%     future_lambda_moment(4,:)=Nesterov.update_step*(aircraft_4.distributed_final_state-aircraft_1.distributed_final_state)';
% 
%     total_moment=Nesterov.update_weight_current*current_lambda_moment+Nesterov.update_weight_future*future_lambda_moment;
% 
%     Nesterov.lambda=temp_lambda+total_moment;
% 
%     Nesterov.history_lambda=[Nesterov.history_lambda;Nesterov.lambda];
% 
%     aircraft_1.decentralized_result=(aircraft_1.P *aircraft_1.u + aircraft_1.Q * x01)' * (aircraft_1.P *aircraft_1.u + aircraft_1.Q * x01)...,
%                                 + aircraft_1.u' * aircraft_1.u + x01'*x01;
%     aircraft_1.error=abs(aircraft_1.decentralized_result-aircraft_1.centralized_result)/aircraft_1.centralized_result;
%     aircraft_1.sub_error=[aircraft_1.sub_error,aircraft_1.error];
% 
%     aircraft_2.decentralized_result=(aircraft_2.P *aircraft_2.u + aircraft_2.Q * x02)' * (aircraft_2.P *aircraft_2.u + aircraft_2.Q * x02)...,
%                                 + aircraft_2.u' * aircraft_2.u + x02'*x02;
%     aircraft_2.error=abs(aircraft_2.decentralized_result-aircraft_2.centralized_result)/aircraft_2.centralized_result;
%     aircraft_2.sub_error=[aircraft_2.sub_error,aircraft_2.error];
% 
%     aircraft_3.decentralized_result=(aircraft_3.P*aircraft_3.u + aircraft_3.Q * x03)' * (aircraft_3.P *aircraft_3.u + aircraft_3.Q * x03)...,
%                                 + aircraft_3.u' * aircraft_3.u + x03'*x03;
%     aircraft_3.error=abs(aircraft_3.decentralized_result-aircraft_3.centralized_result)/aircraft_3.centralized_result;
%     aircraft_3.sub_error=[aircraft_3.sub_error,aircraft_3.error];
% 
%     aircraft_4.decentralized_result=(aircraft_4.P *aircraft_4.u + aircraft_4.Q * x04)' * (aircraft_4.P *aircraft_4.u + aircraft_4.Q * x04)...,
%                                 + aircraft_4.u' * aircraft_4.u + x04'*x04;
%     aircraft_4.error=abs(aircraft_4.decentralized_result-aircraft_4.centralized_result)/aircraft_4.centralized_result;
%     aircraft_4.sub_error=[aircraft_4.sub_error,aircraft_4.error];
% 
%     dual_part=Nesterov.lambda(1,:)*(aircraft_1.distributed_final_state-aircraft_2.distributed_final_state)...,
%                 + Nesterov.lambda(2,:)*(aircraft_2.distributed_final_state-aircraft_3.distributed_final_state)...,
%                 + Nesterov.lambda(3,:)*(aircraft_3.distributed_final_state-aircraft_4.distributed_final_state)...,
%                 + Nesterov.lambda(4,:)*(aircraft_4.distributed_final_state-aircraft_1.distributed_final_state);
% 
%     % dual_part=0;
% 
%     Nesterov.decentralized_result=aircraft_1.decentralized_result + aircraft_2.decentralized_result ...,
%                                         + aircraft_3.decentralized_result + aircraft_4.decentralized_result;
%                                         % + dual_part;
% 
% 
%     Nesterov.error=abs(Nesterov.decentralized_result-Nesterov.centralized_result)/Nesterov.centralized_result
%     Nesterov.error
%     Nesterov.master_error=[Nesterov.master_error,Nesterov.error];
% 
%     i=i+1;
% 
% end
% 
% fixed_step_history_error=Nesterov.master_error;
% 
% figure
% semilogy(Nesterov.master_error(2:end));
%    
% 
% figure('Name','Question 1 Part 3 ML Nestorev master error history')
% semilogy(Nesterov.master_error(2:end));
% title('Question 1 Part 3 ML Nestorev master error history')
% xlabel('iterations')
% ylabel('error')
% grid on
% 
% figure('Name','Question 1 Part 3 ML Nestorev aircraft error history')
% 
% semilogy(aircraft_1.sub_error);
% hold on
% semilogy(aircraft_2.sub_error);
% hold on
% semilogy(aircraft_3.sub_error);
% hold on
% semilogy(aircraft_4.sub_error);
% legend('aircraft 1','aircraft 2','aircraft 3','aircraft 4');
% grid on
% 
% title('aircraft error history')
% xlabel('iterations')
% ylabel('error')
%    
% 
% figure('Name','Question 1 Part 3 ML Nestorev aircrafts final state transitions')
% 
% subplot(2,2,1)
% plot(T_span,aircraft_1.distributed_states');
% title('Question 1 Part 3 ML Nestorev aircraft 1 distributed states')
% xlabel('time')
% ylabel('states')
% grid on
% 
% subplot(2,2,2)
% plot(T_span,aircraft_2.distributed_states');
% title('Question 1 Part 3 ML Nestorev aircraft 2 distributed states')
% xlabel('time')
% ylabel('states')
% grid on
% 
% subplot(2,2,3)
% plot(T_span,aircraft_3.distributed_states');
% title('Question 1 Part 3 ML Nestorev aircraft 3 distributed states')
% xlabel('time')
% ylabel('states')
% grid on
% 
% subplot(2,2,4)
% plot(T_span,aircraft_4.distributed_states');
% title('Question 1 Part 3 ML Nestorev aircraft 4 distributed states')
% xlabel('time')
% ylabel('states')
% grid on



   
