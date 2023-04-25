class AssignmentsController < ApplicationController
    before_action :set_assignment, only: [:show, :edit, :update, :destroy]
    before_action :check_login, only: [:show, :edit, :update, :destroy]
    authorize_resource
  
    def index
      if current_user.role?(:case_worker)
        @parent = Parent.find_by(id: params[:parent_id])
        # All assignments, including complete and incomplete
        @assignment = @parent.assignments
        @incomplete_assignments = @parent.assignments.incomplete.paginate(page: params[:page]).per_page(15)
        @complete_assignments = @parent.assignments.complete.paginate(page: params[:page]).per_page(15)
        # find assignments by parent
      elsif current_user.role?(:parent)
        @assignments = Assignment.for_parent(current_user.parent.id).paginate(page: params[:page]).per_page(15)
        @incomplete_assignments = Assignment.incomplete.for_parent(current_user.parent.id).paginate(page: params[:page]).per_page(15)
        @complete_assignments = Assignment.complete.for_parent(current_user.parent.id).paginate(page: params[:page]).per_page(15)
      end
    end
  
    def new
      @assignment = Assignment.new
    end
  
    def create
      @assignment = Assignment.new(assignment_params)
  
      if @assignment.save
        @parent = @assignment.parent
        redirect_to parent_assignments_path(@parent) 
      else
        render action: 'new'
      end
    end
  
    def edit
    end
  
    def show
      
    end
  
    def update
      if @assignment.update_attributes(assignment_params)
        flash[:notice] = "Successfully updated #{@assignment}."
        redirect_to assignment_path
      else
        render action: 'edit'
      end
    end
  
    def destroy
      @assignment = Assignment.find(params[:id])
      @parent = @assignment.parent
      @item = @assignment.item
    
      begin
        @assignment.destroy!
        flash[:success] = 'Assignment was successfully deleted.'
        redirect_to parent_assignments_path(@parent) 
      rescue ActiveRecord::InvalidForeignKey => e
        flash[:error] = 'Cannot delete this Assignment: there are associated Submissions.'
        redirect_to parent_show_path(id: @item.id, parent_id: @parent.id)
      end

    end

    
    private
      def set_assignment
        @assignment = Assignment.find(params[:id])
      end

      def assignment_params
        params.require(:assignment).permit(:due_date, :completion, :status, :parent_id, :item_id)
      end
end
