class StripeAccount < ActiveRecord::Base

  def getPublic
    return test_public_token
  end

  def getPrivate
    return test_private_token
  end

end
