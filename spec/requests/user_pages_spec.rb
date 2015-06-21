require 'rails_helper'

RSpec.describe "User pages", :type => :request do

	subject{page}

	describe  "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		let!(:m1){ FactoryGirl.create(:micropost,user:user,content:"foo")}
		let!(:m2){ FactoryGirl.create(:micropost,user:user,content:"bar")}
		before { visit user_path(user) }
		it { should have_content(user.name)}
		it { should have_title(user.name)}	
		
		describe "microposts" do
			it {should have_content(m1.content)}
			it {should have_content(m2.content)}
			it {should have_content(user.microposts.count)}
		end 
	end

	describe "signup" do

		before { visit signup_path }	
		let(:submit){"提交"}

		describe "with invalid information"	 do
			it "should not create a user"	do
				expect {click_button submit }.not_to change(User,:count)
			end
		end

		describe "with valid information" do
			before do
				fill_in "姓名"	,with:"chenhui"
				fill_in "邮件",with:"chenhui@sohu.com"
				fill_in "密码",with:"foobar"
				fill_in "确认密码",with:"foobar"
			end

			it "should create a user" do
				expect{ click_button submit }.to change(User,:count).by(1)
			end

			describe "after saving the user" do
				before { click_button  submit}	
				let(:user) { User.find_by(email:'chenhui@sohu.com')}

				it { should have_link('退出') }
				it { should have_title(user.name) }
				it { should have_selector('div.alert.alert-success',text:'Welcome')}
			end
			
		end
	end
	
	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before do
			sign_in  user
			visit edit_user_path(user) 
		end 
		
			
		describe "page" do
			it { should have_content("编辑个人资料") }
			it { should have_title("Edit user") }
			it { should have_link('change', href: 'http://gravatar.com/emails') }
		end
		
		describe "with invalid information" do
			before  { click_button "保存" }
			it { should have_content("short") }
		end

		describe "with valid information" do
			let(:new_name)	{ "New Name"}
			let(:new_email){ "new@sohu.com"}
			before do
				fill_in "姓名"	,with:new_name
				fill_in "邮件",with:new_email
				fill_in "密码",with:"foobarfoobar"
				fill_in "确认密码",with:"foobarfoobar"
				click_button "保存"
			end
			it { should have_title(new_name)}
			it { should have_selector('div.alert.alert-success')}
			it  { should have_link("退出",href:signout_path)}

			specify{ expect(user.reload.name).to eq new_name }
			specify{ expect(user.reload.email).to eq new_email }
		end
	end
	
	describe "index" do
		before do
			sign_in FactoryGirl.create(:user)
			FactoryGirl.create(:user,name:"Bob",email:"bob@sohu.com")
			FactoryGirl.create(:user,name:"ben",email:"ben@sohu.com")
			visit users_path
		end	
		it { should have_title("所有用户")	}
		it { should have_content("所有用户") }
		
		describe "pagination" do
			before(:all){5.times{FactoryGirl.create(:user)}}
			after(:all){User.delete_all}
			
			# it { should have_selector('div#pagination')}	
			
			
			it "should list each user" do
				User.paginate(page:1).each  do |user|
					expect(page).to have_selector('li',text:user.name)
				end
			end
			

		end
			it "should list each user"	do
				User.all.each do |user|
					expect(page).to have_selector('li',text:user.name)
				end
			end	

	end
	
	describe "delete links" do
		it { should_not have_link('delete') }
		before(:all){5.times{FactoryGirl.create(:user)}}
		after(:all){User.delete_all}
		
		describe "as an admin" do
			
			let(:admin) {FactoryGirl.create(:admin) }
			before do
				sign_in admin
				visit users_path
			end
			
			it {should have_link('delete',href:user_path(User.second)) }
			
			it "should be able to delete another user"	do
				expect do
					click_link('delete',match: :first)
				end.to change(User,:count).by(-1)
			end
			
			it { should_not have_link('delete',href:user_path(admin))	}
		end
	end
end
