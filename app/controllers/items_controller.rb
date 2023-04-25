class ItemsController < ApplicationController
    before_action :set_item, only: [:show, :edit, :update, :toggle_active_item, :destroy]
    before_action :check_login, only: [:show, :edit, :update, :destroy]
    authorize_resource
  
    def new
      @item = Item.new
    end
  
    def create
      @item = Item.new(item_params)
  
      if @item.save
        flash[:notice] = "#{@item.name} was added to the system."
        redirect_to category_path(@item.category)
      else
        render action: 'new'
      end
    end
  
    def edit
    end
  
    def show
      if current_user.role?(:parent)
        @parent = current_user.parent
        # all assignments that have been assigned to the user
        @assignments = Assignment.for_parent(current_user.parent.id).paginate(page: params[:page]).per_page(15)
        
        @item = Item.find(params[:id])
        parent_assignments = @assignments.select { |assignment| assignment.item == @item }
        @submissions = parent_assignments.map(&:submission).compact
      end   
    end

    def parent_show
      if current_user.role?(:case_worker)
        # all assignments that have been assigned to the particular parent that I'm looking at
        @item = Item.find(params[:id])
        @parent = Parent.find(params[:parent_id])
        @assignments = Assignment.where(item: @item, parent: @parent)
        
        @submissions = Submission.joins(:assignment)
                         .where(assignments: { id: @assignments.pluck(:id) })
                         .chronological
      end
    end
  
    def update
      if @item.update_attributes(item_params)
        flash[:notice] = "Successfully updated #{@item.name}."
        redirect_to item_path
      else
        render action: 'edit'
      end
    end

    def destroy
      @item = Item.find(params[:id])
      #@submission = @item.assignment.submission
      @category = @item.category
    
      begin
        @item.destroy!
        flash[:success] = 'Item was successfully deleted.'
        redirect_to category_path(@category)
      rescue ActiveRecord::InvalidForeignKey => e
        flash[:error] = 'Cannot delete this Item: there are associated Assignments or Submissions.'
        redirect_to item_path(@item)
      end
    end

    def toggle_active_item
      if @item.active
        @item.update_attribute(:active, false)
        @item.save

        flash[:notice] = "#{@item.name} was made inactive"
        redirect_to item_path(@item)
      else
        @item.update_attribute(:active, true)
        @item.save

        flash[:notice] = "#{@item.name} was made active"
        redirect_to item_path(@item)
      end
  end
  
    private
      def set_item
        @item = Item.find(params[:id])
      end
  
      def item_params
        params.require(:item).permit(:name, :instructions, :filename, :file, :due_date, :active, :category_id)
      end
  
  end
  