insert into user_registration.user(user_registration.user.id, user_registration.user.email,
                                   user_registration.user.enabled, user_registration.user.first_name,
                                   user_registration.user.last_name, user_registration.user.password,
                                   user_registration.user.role)
values (1, 'hi@vmodev.com', true, 'vmo', 'dev', '$2a$11$AEMs1n.yuZluEO5Fi.oPEeK8z6xHRFeHhW9auUdV79exXcn9hoILW', 'user')