module UsersHelper

  def user_current_role_human_readable(ucr)
    ret = ucr.current_role.name.dup
    ret << ": "
    ret << ucr.uic.number.to_s if ucr.uic
    ret << " "
    ret << ucr.region.name if ucr.region
    ret
  end

end
