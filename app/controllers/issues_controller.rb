class IssuesController < ApplicationController
  before_action :get_context

  def index
    @issues = find_issue(params[:state])
    @issues = @issues.tagged_with(params[:tag]) if params[:tag]
  end

  def new
    @issue = Issue.new
  end

  def show
    @issue = @project.issues.find_by_sub_id(params[:id])
    @comments = Comment.where(
      polycomment_type: 'issue',
      polycomment_id: @issue.id
    )
    @comments = pg @comments, 10
    @comment = Comment.new
    @ajax = params[:page].nil? || params[:page] == 1
  end

  def create
    @issue = Issue.new(issue_params)
    @issue.user = current_user
    @issue.project = @project
    @issue.status = 0
    respond_to do |format|
      if @issue.save
        @issue.tag_list.each do |tag|
          unless @project.tag_list.include?(tag)
            @project.tag_list.add(tag)
            @project.save
          end
        end
        victims = @project.followers + [@project.user] - [@issue.user]
        notify_users 'issue_create', 0, @project.id, victims
        format.html { redirect_to @issue.show_url }
      else
        format.html { render 'new'}
      end
    end
  end

  # TODO: Needs a revisit after defining abilities
  # PUT /user/project/issues/1/close
  def close
    @issue = @project.issues.find_by_sub_id(params[:id])
    if (current_user == @project.user) || (current_user == @issue.user)
      if @issue.close
        flash[:notice] = 'Issue Closed'
        redirect_to project_issues_path(@project)
      else
        flash[:notice] = 'Something went wrong. The issue was not closed'
        redirect_to issue_path(@issue)
      end
    else
      flash[:alert] = "You don't have permission to close this issue"
      redirect_to issue_path(@issue)
    end
  end

  # PUT /user/project/issues/1/reopen
  def reopen
    @issue = @project.issues.find_by_sub_id(params[:id])
    if @issue.reopen
      flash[:notice] = 'Issue Reopened'
    else
      flash[:notice] = 'Something went wrong. The issue was not Reopened'
    end
    redirect_to issue_path @issue
  end

  private

  def get_context
    @user = User.find_by username: params[:user_id]
    @project = Project.find_by user_id: @user.id, name: params[:project_id]
  end

  def issue_params
    params.require(:issue).permit(:title, :description, :tag_list)
  end

  def find_issue(type)
    if type == 'closed'
      @activetab = 1
      @project.issues.where(status: 1)
    else
      @activetab = 0
      @project.issues.where(status: 0)
    end
  end
end
