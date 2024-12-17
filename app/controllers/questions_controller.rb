class QuestionsController < ApplicationController

  def index
    @questions = current_user.questions
    @question = Question.new # for form
  end

  def create
    @question = current_user.questions
    @question = Question.new(question_params)
    @question.user = current_user

    if @question.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(:questions, partial: "questions/question",
                 locals: { question: @question })
        end
      end
    else
      render :index, status: :unprocessable_entity
    end

  end

  private

  def question_params
    params.require(:question).permit(:user_question)
  end
end
