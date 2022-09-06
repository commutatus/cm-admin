class CmAdmin::FileImportPolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    true
  end

end