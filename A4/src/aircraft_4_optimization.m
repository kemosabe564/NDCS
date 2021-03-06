%%%%%  aircraft 4

%%%%% aircraft 4 for Question 1a

if (Index=="1a" || Index=="1b")

        aircraft_4.options=optimoptions('quadprog','Display','off');

        aircraft_4.H=aircraft_4.P'*aircraft_4.P;
        aircraft_4.H=aircraft_4.H+eye(length_action);
        aircraft_4.f=aircraft_4.initial_state'*aircraft_4.Q'*aircraft_4.P*2;
        aircraft_4.f=aircraft_4.f+(decompose_problem.lambda(4,:)-decompose_problem.lambda(3,:))*aircraft_4.matrix;
        aircraft_4.f=aircraft_4.f';

        aircraft_4.u_lb=-aircraft_4.input_max*ones(length_action,1);
        aircraft_4.u_ub=aircraft_4.input_max*ones(length_action,1);
        

        [u4,fval,exitflag]=quadprog(2*aircraft_4.H,aircraft_4.f,[],[],[],[],aircraft_4.u_lb,aircraft_4.u_ub,[],aircraft_4.options);


%%%%% aircraft 4 for Question 1c

elseif (Index=="1c" )

        aircraft_4.options=optimoptions('quadprog','Display','off');

        aircraft_4.H=aircraft_4.P'*aircraft_4.P;
        aircraft_4.H=aircraft_4.H+eye(length_action);
        aircraft_4.f=aircraft_4.initial_state'*aircraft_4.Q'*aircraft_4.P*2;
        aircraft_4.f=aircraft_4.f+(Nesterov.lambda(4,:)-Nesterov.lambda(3,:))*aircraft_4.matrix;
        aircraft_4.f=aircraft_4.f';

        aircraft_4.u_lb=-aircraft_4.input_max*ones(length_action,1);
        aircraft_4.u_ub=aircraft_4.input_max*ones(length_action,1);
        

        [u4,fval,exitflag]=quadprog(2*aircraft_4.H,aircraft_4.f,[],[],[],[],aircraft_4.u_lb,aircraft_4.u_ub,[],aircraft_4.options);


%%%%% aircraft 4 for Question 1d

elseif (Index=="1d")

        aircraft_4.options=optimoptions('quadprog','Display','off');

        aircraft_4.H=aircraft_4.P'*aircraft_4.P;
        aircraft_4.H=aircraft_4.H+eye(length_action);
        aircraft_4.f=aircraft_4.initial_state'*aircraft_4.Q'*aircraft_4.P*2;
        aircraft_4.f=aircraft_4.f+(aircraft_4.lambda(4,:)-aircraft_4.lambda(3,:))*aircraft_4.matrix;
        aircraft_4.f=aircraft_4.f';

        aircraft_4.u_lb=-aircraft_4.input_max*ones(length_action,1);
        aircraft_4.u_ub=aircraft_4.input_max*ones(length_action,1);
        

        [u4,fval,exitflag]=quadprog(2*aircraft_4.H,aircraft_4.f,[],[],[],[],aircraft_4.u_lb,aircraft_4.u_ub,[],aircraft_4.options);


%%%%% aircraft 4 for Question 1e


elseif (Index=="1e")

        cvxp = cvx_precision( 'best' );
        cvx_begin  sdp quiet
        
            cvx_solver gurobi
        
            variables u4(length_action,1)
        
        
            minimize ((aircraft_4.P *u4 + aircraft_4.Q * aircraft_4.initial_state)' * (aircraft_4.P *u4 + aircraft_4.Q * aircraft_4.initial_state)+u4'*u4 ...,
            + (decompose_problem.lambda(4,:)-decompose_problem.lambda(3,:))*(aircraft_4.matrix*u4+aircraft_4.A^5*aircraft_4.initial_state)...,
            + x01'*x01)

            subject to

            sum_square(u4)<=umax^2;
        
        
        cvx_end
        cvx_precision( cvxp );



%%%%% aircraft 4 for Question 2.1


elseif (Index=="2_1a")

        cvx_clear

        cvx_begin quiet

        variable u4(length_action,1)

        minimize ((aircraft_4.P *u4(1:aircraft_4.nx_input) + aircraft_4.Q * aircraft_4.initial_state)' * (aircraft_4.P *u4(1:aircraft_4.nx_input) + aircraft_4.Q * aircraft_4.initial_state)+u4'*u4 ...,
                + (aircraft_4.lambda)*(aircraft_4.matrix*u4+aircraft_4.A^5*aircraft_4.initial_state-ADMM_2a.terminal)...,
                + aircraft_4.rho/2*sum_square(aircraft_4.matrix*u4+aircraft_4.A^5*aircraft_4.initial_state-ADMM_2a.terminal) ...,
                + x04'*x04)


        subject to

                u4 <= aircraft_4.input_max * ones(length_action,1);
                u4 >= -aircraft_4.input_max * ones(length_action,1);

        cvx_end

end

% final state

aircraft_4.distributed_final_state=aircraft_4.matrix*u4+aircraft_4.A^5*aircraft_4.initial_state;
aircraft_4.distributed_final_state;

% aircraft_4.history_final_state=[aircraft_4.history_final_state,aircraft_4.distributed_final_state];
aircraft_4.u=u4;